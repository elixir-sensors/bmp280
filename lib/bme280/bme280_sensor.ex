defmodule BME280.Sensor do
  @moduledoc false

  alias BMP2XX.{Calc, Measurement, Sensor}

  defstruct [
    :calibration,
    :sea_level_pa,
    :transport
  ]

  defimpl Sensor do
    @impl true
    def init(%{transport: transport} = state) do
      with :ok <- BME280.Comm.set_oversampling(transport),
           {:ok, calibration_binary} <- BME280.Comm.read_calibration(transport) do
        calibration = BME280.Calibration.from_binary(calibration_binary)
        %{state | calibration: calibration}
      end
    end

    @impl true
    def read(%{transport: transport} = state) do
      case BME280.Comm.read_raw_samples(transport) do
        {:ok, raw_samples} -> {:ok, BME280.Sensor.measurement_from_raw_samples(raw_samples, state)}
        error -> error
      end
    end
  end

  @spec measurement_from_raw_samples(<<_::64>>, Sensor.t()) :: Measurement.t()
  def measurement_from_raw_samples(raw_samples, state) do
    <<raw_pressure::20, _::4, raw_temperature::20, _::4, raw_humidity::16>> = raw_samples
    %{calibration: calibration, sea_level_pa: sea_level_pa} = state

    temperature_c = BME280.Calibration.raw_to_temperature(calibration, raw_temperature)
    pressure_pa = BME280.Calibration.raw_to_pressure(calibration, temperature_c, raw_pressure)
    humidity_rh = BME280.Calibration.raw_to_humidity(calibration, temperature_c, raw_humidity)

    # Derived calculations
    altitude_m = Calc.pressure_to_altitude(pressure_pa, sea_level_pa)
    dew_point_c = Calc.dew_point(humidity_rh, temperature_c)

    %Measurement{
      temperature_c: temperature_c,
      pressure_pa: pressure_pa,
      altitude_m: altitude_m,
      humidity_rh: humidity_rh,
      dew_point_c: dew_point_c,
      gas_resistance_ohms: :unknown,
      timestamp_ms: System.monotonic_time(:millisecond)
    }
  end
end