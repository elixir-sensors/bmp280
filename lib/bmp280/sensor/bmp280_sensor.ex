defmodule BMP280.BMP280Sensor do
  @moduledoc false

  alias BMP280.{Calc, BMP280Calibration, BMP280Comm, Measurement}

  @behaviour BMP280.Sensor

  @type raw_samples() :: %{
          raw_pressure: non_neg_integer(),
          raw_temperature: non_neg_integer()
        }

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

  @spec measurement_from_raw_samples(raw_samples(), BMP280.state()) :: BMP280.Measurement.t()
  def measurement_from_raw_samples(raw, %{calibration: calibration, sea_level_pa: sea_level_pa}) do
    temperature_c = BMP280Calibration.raw_to_temperature(calibration, raw.raw_temperature)
    pressure_pa = BMP280Calibration.raw_to_pressure(calibration, temperature_c, raw.raw_pressure)

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
