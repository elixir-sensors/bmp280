defmodule BMP280.BME680Sensor do
  @moduledoc false

  alias BMP280.{BME680Calibration, BME680Comm, Calc, Comm, Measurement}

  @behaviour BMP280.Sensor

  @type raw_samples() :: %{
          raw_pressure: non_neg_integer(),
          raw_temperature: non_neg_integer(),
          raw_humidity: non_neg_integer(),
          raw_gas_resistance: non_neg_integer(),
          raw_gas_range: non_neg_integer()
        }

  @type heater_duration_ms() :: 1..4032
  @type heater_temperature_c() :: 200..400

  @heater_temperature_c 300
  @heater_duration_ms 100
  @ambient_temperature_c 25

  @impl true
  def init(%{transport: transport} = initial_state) do
    with :ok <- Comm.reset(transport),
         {:ok, cal_binary} <- BME680Comm.read_calibration(transport),
         calibration <- BME680Calibration.from_binary(cal_binary),
         :ok <- BME680Comm.set_oversampling(transport),
         :ok <- BME680Comm.set_filter(transport),
         :ok <- BME680Comm.enable_gas_sensor(transport),
         :ok <-
           BME680Comm.set_gas_heater_temperature(
             transport,
             heater_resistance_code(calibration, @heater_temperature_c, @ambient_temperature_c)
           ),
         :ok <-
           BME680Comm.set_gas_heater_duration(
             transport,
             heater_duration_code(@heater_duration_ms)
           ),
         :ok <- BME680Comm.set_gas_heater_profile(transport, 0),
         do: %{initial_state | calibration: calibration}
  end

  @impl true
  def read(%{transport: transport} = state) do
    case BME680Comm.read_raw_samples(transport) do
      {:ok, raw_samples} -> {:ok, measurement_from_raw_samples(raw_samples, state)}
      error -> error
    end
  end

  @spec measurement_from_raw_samples(<<_::80>>, BMP280.Sensor.t()) :: BMP280.Measurement.t()
  def measurement_from_raw_samples(raw_samples, state) do
    <<raw_pressure::20, _::4, raw_temperature::20, _::4, raw_humidity::16, _::16>> = raw_samples
    <<_::64, raw_gas_resistance::10, _::2, raw_gas_range::4>> = raw_samples
    %{calibration: calibration, sea_level_pa: sea_level_pa} = state

    temperature_c = BME680Calibration.raw_to_temperature(calibration, raw_temperature)
    pressure_pa = BME680Calibration.raw_to_pressure(calibration, temperature_c, raw_pressure)
    humidity_rh = BME680Calibration.raw_to_humidity(calibration, temperature_c, raw_humidity)

    gas_resistance_ohms =
      BME680Calibration.raw_to_gas_resistance(
        calibration,
        raw_gas_resistance,
        raw_gas_range
      )

    # Derived calculations
    altitude_m = Calc.pressure_to_altitude(pressure_pa, sea_level_pa)
    dew_point_c = Calc.dew_point(humidity_rh, temperature_c)

    %Measurement{
      temperature_c: temperature_c,
      pressure_pa: pressure_pa,
      altitude_m: altitude_m,
      humidity_rh: humidity_rh,
      dew_point_c: dew_point_c,
      gas_resistance_ohms: gas_resistance_ohms,
      timestamp_ms: System.monotonic_time(:millisecond)
    }
  end

  @doc """
  Convert the heater temperature into a register code.

  ## Examples

      iex> cal = %{
      ...>   par_gh1: -30,
      ...>   par_gh2: -5969,
      ...>   par_gh3: 18,
      ...>   res_heat_val: 50,
      ...>   res_heat_range: 1,
      ...>   range_switching_error: 1
      ...> }
      iex> BME680Sensor.heater_resistance_code(cal, 300, 28)
      112
  """
  @spec heater_resistance_code(BME680Calibration.t(), heater_temperature_c(), integer()) ::
          integer()
  def heater_resistance_code(cal, heater_temp_c, amb_temp_c) do
    %{
      par_gh1: par_gh1,
      par_gh2: par_gh2,
      par_gh3: par_gh3,
      res_heat_range: res_heat_range,
      res_heat_val: res_heat_val
    } = cal

    var1 = par_gh1 / 16.0 + 49.0
    var2 = par_gh2 / 32_768.0 * 0.0005 + 0.00235
    var3 = par_gh3 / 1024.0
    var4 = var1 * (1.0 + var2 * heater_temp_c)
    var5 = var4 + var3 * amb_temp_c

    round(
      3.4 *
        (var5 * (4.0 / (4.0 + res_heat_range)) *
           (1.0 /
              (1.0 +
                 res_heat_val * 0.002)) - 25)
    )
  end

  @doc """
  Convert the heater duration milliseconds into a register code. Heating durations between 1 ms and
  4032 ms can be configured. In practice, approximately 20–30 ms are necessary for the heater to
  reach the intended target temperature.

  ## Examples

      iex> BME680Sensor.heater_duration_code(63)
      63
      iex> BME680Sensor.heater_duration_code(64)
      80
      iex> BME680Sensor.heater_duration_code(100)
      89
      iex> BME680Sensor.heater_duration_code(4032)
      255
      iex> BME680Sensor.heater_duration_code(4033)
      ** (FunctionClauseError) no function clause matching in BMP280.BME680Sensor.heater_duration_code/2
  """
  @spec heater_duration_code(heater_duration_ms(), non_neg_integer()) :: non_neg_integer()
  def heater_duration_code(duration, factor \\ 0)

  def heater_duration_code(duration, factor) when duration in 64..4032 do
    duration |> div(4) |> heater_duration_code(factor + 1)
  end

  def heater_duration_code(duration, factor) when duration in 1..63 do
    duration + factor * 64
  end
end
