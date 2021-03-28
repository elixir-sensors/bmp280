defmodule BMP280.BMP388Sensor do
  @moduledoc false

  alias BMP280.{Calc, BMP388Calibration, BMP388Comm, Measurement}

  @behaviour BMP280.Sensor

  @type raw_samples() :: %{
          raw_pressure: non_neg_integer(),
          raw_temperature: non_neg_integer()
        }

  @impl true
  def init(%{sensor_type: :bmp388, transport: transport} = state) do
    with :ok <- BMP388Comm.reset(transport),
         :ok <- BMP388Comm.set_power_control_settings(transport),
         :ok <- BMP388Comm.set_odr_and_filter_settings(transport),
         :ok <- BMP388Comm.set_interrupt_control_settings(transport),
         :ok <- BMP388Comm.set_serial_interface_settings(transport),
         {:ok, calibration_binary} <- BMP388Comm.read_calibration(transport),
         calibration <- BMP388Calibration.from_binary(calibration_binary),
         do: %{state | calibration: calibration}
  end

  @impl true
  def read(%{transport: transport} = state) do
    case BMP388Comm.read_raw_samples(transport) do
      {:ok, raw_samples} -> {:ok, measurement_from_raw_samples(raw_samples, state)}
      error -> error
    end
  end

  @spec measurement_from_raw_samples(raw_samples(), BMP280.state()) :: Measurement.t()
  def measurement_from_raw_samples(raw_samples, state) do
    %{calibration: calibration, sea_level_pa: sea_level_pa} = state

    %{temperature_c: temperature_c, pressure_pa: pressure_pa} =
      BMP388Calibration.temperature_and_pressure_from_raw_samples(calibration, raw_samples)

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
