defmodule BMP180.Sensor do
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
      with {:ok, calibration_binary} <- BMP180.Comm.read_calibration(transport),
           calibration <- BMP180.Calibration.from_binary(calibration_binary),
           do: %{state | calibration: calibration}
    end

    @impl true
    def read(%{transport: transport} = state) do
      :ok = BMP180.Comm.set_temperature_reading(transport)
      Process.sleep(10)
      {:ok, raw_temperature} = BMP180.Comm.read_raw_samples(transport)
      :ok = BMP180.Comm.set_pressure_reading(transport)
      Process.sleep(10)
      {:ok, raw_pressure} = BMP180.Comm.read_raw_samples(transport)
      {:ok, BMP180.Sensor.measurement_from_raw_samples(raw_temperature, raw_pressure, state)}
    end
  end

  @spec measurement_from_raw_samples(<<_::24>>, <<_::24>>, Sensor.t()) :: Measurement.t()
  def measurement_from_raw_samples(raw_temperature, raw_pressure, state) do
    %{calibration: calibration, sea_level_pa: sea_level_pa} = state

    temperature_c = BMP180.Calibration.raw_to_temperature(calibration, raw_temperature)
    pressure_pa = BMP180.Calibration.raw_to_pressure(calibration, temperature_c, raw_pressure)

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
