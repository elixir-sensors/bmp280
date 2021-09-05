defmodule BMP280.BMP180Sensor do
  @moduledoc false

  alias BMP280.{BMP180Calibration, BMP180Comm, Calc, Measurement}

  @behaviour BMP280.Sensor

  @impl true
  def init(%{sensor_type: :bmp180, transport: transport} = state) do
    with {:ok, calibration_binary} <- BMP180Comm.read_calibration(transport),
         calibration <- BMP180Calibration.from_binary(calibration_binary),
         do: %{state | calibration: calibration}
  end

  @impl true
  def read(%{transport: transport} = state) do
    BMP180Comm.set_temperature_reading(transport)
    {:ok, raw_temperature} = BMP180Comm.read_raw_samples(transport)
    BMP180Comm.set_pressure_reading(transport)
    {:ok, raw_pressure} = BMP180Comm.read_raw_samples(transport)
    {:ok, measurement_from_raw_samples(raw_temperature, raw_pressure, state)}
  end

  @spec measurement_from_raw_samples(<<_::16>>, <<_::16>>, BMP180.Sensor.t()) ::
          BMP180.Measurement.t()
  def measurement_from_raw_samples(raw_temperature, raw_pressure, state) do
    <<raw_temperature::16>> = s(raw_temperature)
    <<raw_pressure::16>> = s(raw_pressure)
    %{calibration: calibration, sea_level_pa: sea_level_pa} = state

    temperature_c = BMP180Calibration.raw_to_temperature(calibration, raw_temperature)
    pressure_pa = BMP180Calibration.raw_to_pressure(calibration, temperature_c, raw_pressure)

    # Derived calculations
    # altitude_m = Calc.pressure_to_altitude(pressure_pa, sea_level_pa)

    %Measurement{
      temperature_c: temperature_c,
      pressure_pa: pressure_pa,
      altitude_m: :unknown,
      humidity_rh: :unknown,
      dew_point_c: :unknown,
      gas_resistance_ohms: :unknown,
      timestamp_ms: System.monotonic_time(:millisecond)
    }
  end

  defp s(data), do: data
end
