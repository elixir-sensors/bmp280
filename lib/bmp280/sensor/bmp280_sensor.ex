defmodule BMP280.BMP280Sensor do
  @moduledoc false

  alias BMP280.BMP280Calibration
  alias BMP280.BMP280Comm
  alias BMP280.Calc
  alias BMP280.Measurement

  @behaviour BMP280.Sensor

  @impl true
  def init(%{sensor_type: :bmp280, transport: transport} = state) do
    with :ok <- BMP280Comm.set_oversampling(transport),
         {:ok, calibration_binary} <- BMP280Comm.read_calibration(transport),
         calibration <- BMP280Calibration.from_binary(calibration_binary),
         do: %{state | calibration: calibration}
  end

  @impl true
  def read(%{transport: transport} = state) do
    case BMP280Comm.read_raw_samples(transport) do
      {:ok, raw_samples} -> {:ok, measurement_from_raw_samples(raw_samples, state)}
      error -> error
    end
  end

  @spec measurement_from_raw_samples(<<_::48>>, BMP280.Sensor.t()) :: BMP280.Measurement.t()
  def measurement_from_raw_samples(raw_samples, state) do
    <<raw_pressure::20, _::4, raw_temperature::20, _::4>> = raw_samples
    %{calibration: calibration, sea_level_pa: sea_level_pa} = state

    temperature_c = BMP280Calibration.raw_to_temperature(calibration, raw_temperature)
    pressure_pa = BMP280Calibration.raw_to_pressure(calibration, temperature_c, raw_pressure)

    # Derived calculations
    altitude_m = Calc.pressure_to_altitude(pressure_pa, sea_level_pa)

    %Measurement{
      temperature_c: temperature_c,
      pressure_pa: pressure_pa,
      altitude_m: altitude_m,
      humidity_rh: :unknown,
      dew_point_c: :unknown,
      gas_resistance_ohms: :unknown,
      timestamp_ms: System.monotonic_time(:millisecond)
    }
  end
end
