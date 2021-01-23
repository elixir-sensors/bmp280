defmodule BMP280.Calc do
  alias BMP280.{Calibration, Measurement}
  @moduledoc false

  @typedoc false
  @type raw() :: %{
          required(:raw_pressure) => non_neg_integer(),
          required(:raw_temperature) => non_neg_integer(),
          optional(:raw_humidity) => non_neg_integer()
        }

  @doc """
  Convert raw sensor reports to temperature, pressure and altitude measurements
  """
  @spec raw_to_measurement(Calibration.t(), number(), raw()) :: Measurement.t()
  def raw_to_measurement(cal, sea_level_pa, raw) do
    # Direct calculations
    temp = Calibration.raw_to_temperature(cal, raw.raw_temperature)
    pressure = Calibration.raw_to_pressure(cal, temp, raw.raw_pressure)
    humidity = Calibration.raw_to_humidity(cal, temp, Map.get(raw, :raw_humidity))

    # Derived calculations
    altitude = pressure_to_altitude(pressure, sea_level_pa)
    dew_point = dew_point(humidity, temp)

    %Measurement{
      temperature_c: temp,
      pressure_pa: pressure,
      altitude_m: altitude,
      humidity_rh: humidity,
      dew_point_c: dew_point
    }
  end

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

  @doc """
  Calculate the dew point

  This uses the August–Roche–Magnus approximation. See
  https://en.wikipedia.org/wiki/Clausius%E2%80%93Clapeyron_relation#Meteorology_and_climatology
  """
  @spec dew_point(number() | :unknown, number()) :: float() | :unknown
  def dew_point(humidity_rh, temperature_c) when is_number(humidity_rh) and humidity_rh > 0 do
    log_rh = :math.log(humidity_rh / 100)
    t = temperature_c

    243.04 * (log_rh + 17.625 * t / (243.04 + t)) / (17.625 - log_rh - 17.625 * t / (243.04 + t))
  end

  def dew_point(_humidity_rh, _temperature_c) do
    :unknown
  end
end
