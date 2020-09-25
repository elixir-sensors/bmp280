defmodule BMP280.Calc do
  alias BMP280.{Calibration, Measurement}
  @moduledoc false

  @doc """
  Convert raw sensor reports to temperature, pressure and altitude measurements
  """
  @spec raw_to_measurement(Calibration.t(), number(), map()) :: Measurement.t()
  def raw_to_measurement(%Calibration{} = cal, sea_level_pa, raw) do
    temp = raw_to_temperature(cal, raw.raw_temperature)

    pressure = raw_to_pressure(cal, temp, raw.raw_pressure)
    altitude = pressure_to_altitude(pressure, sea_level_pa)
    humidity = raw_to_humidity(cal, temp, Map.get(raw, :raw_humidity))

    %Measurement{
      temperature_c: temp,
      pressure_pa: pressure,
      altitude_m: altitude,
      humidity_rh: humidity
    }
  end

  defp raw_to_temperature(cal, raw_temp) do
    var1 = (raw_temp / 16384 - cal.dig_T1 / 1024) * cal.dig_T2

    var2 =
      (raw_temp / 131_072 - cal.dig_T1 / 8192) * (raw_temp / 131_072 - cal.dig_T1 / 8192) *
        cal.dig_T3

    (var1 + var2) / 5120
  end

  defp raw_to_pressure(cal, temp, raw_pressure) do
    t_fine = temp * 5120

    var1 = t_fine / 2 - 64000
    var2 = var1 * var1 * cal.dig_P6 / 32768
    var2 = var2 + var1 * cal.dig_P5 * 2
    var2 = var2 / 4 + cal.dig_P4 * 65536
    var1 = (cal.dig_P3 * var1 * var1 / 524_288 + cal.dig_P2 * var1) / 524_288
    var1 = (1 + var1 / 32768) * cal.dig_P1
    p = 1_048_576 - raw_pressure
    p = (p - var2 / 4096) * 6250 / var1
    var1 = cal.dig_P9 * p * p / 2_147_483_648
    var2 = p * cal.dig_P8 / 32768
    p = p + (var1 + var2 + cal.dig_P7) / 16

    p
  end

  defp raw_to_humidity(%{has_humidity?: true} = cal, temp, raw_humidity)
       when is_integer(raw_humidity) do
    t_fine = temp * 5120
    var_H = t_fine - 76800

    var_H =
      (raw_humidity - (cal.dig_H4 * 64 + cal.dig_H5 / 16384 * var_H)) *
        (cal.dig_H2 / 65536 *
           (1 +
              cal.dig_H6 / 67_108_864 * var_H *
                (1 + cal.dig_H3 / 67_108_864 * var_H)))

    var_H = var_H * (1 - cal.dig_H1 * var_H / 524_288)

    min(100, max(0, var_H))
  end

  defp raw_to_humidity(_cal, _temp, _raw), do: 0

  @doc """
  Calculate the altitude using the current pressure and sea level pressure
  """
  @spec pressure_to_altitude(number(), number()) :: float()
  def pressure_to_altitude(p, sea_level_pa) do
    44330 * (1 - :math.pow(p / sea_level_pa, 1 / 5.255))
  end

  @doc """
  Calculate the sea level pressure based on the specified altitude
  """
  @spec sea_level_pressure(number(), number()) :: float()
  def sea_level_pressure(p, altitude) do
    p / :math.pow(1 - altitude / 44330, 5.255)
  end
end
