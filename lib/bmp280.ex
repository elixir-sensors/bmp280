defmodule BMP280 do
  use GenServer
  require Logger

  alias BMP280.{Calc, Comm, Measurement, Transport}

  @sea_level_pa 100_000
  @default_bmp280_bus_address 0x77
  @polling_interval 1000

  @typedoc """
  The type of sensor in use

  If the sensor is unknown, then number in the parts ID register is used.
  """
  @type sensor_type() :: :bmp180 | :bmp280 | :bme280 | :bme680 | 0..255

  @moduledoc """
  Read temperature and pressure from a Bosch BM280, BME280, or BME680 sensor
  """

  @typedoc """
  BMP280 GenServer start_link options

  * `:name` - a name for the GenServer
  * `:bus_name` - which I2C bus to use (e.g., `"i2c-1"`)
  * `:bus_address` - the address of the BMP280 (defaults to 0x77)
  * `:sea_level_pa` - a starting estimate for the sea level pressure in Pascals
  """
  @type options() :: [
          name: GenServer.name(),
          bus_name: String.t(),
          bus_address: 0x76 | 0x77,
          sea_level_pa: number()
        ]

  @doc """
  Start a new GenServer for interacting with a BMP280

  Normally, you'll want to pass the `:bus_name` option to specify the I2C
  bus going to the BMP280.
  """
  @spec start_link(options()) :: GenServer.on_start()
  def start_link(init_arg) do
    options = Keyword.take(init_arg, [:name])
    GenServer.start_link(__MODULE__, init_arg, options)
  end

  @doc """
  Return the type of sensor

  This function returns the cached result of reading the ID register.
  if the part is recognized. If not, it returns the integer read.
  """
  @spec sensor_type(GenServer.server()) :: sensor_type()
  def sensor_type(server) do
    GenServer.call(server, :sensor_type)
  end

  @doc """
  Measure the current temperature, pressure, altitude

  An error is return if the I2C transactions fail.
  """
  @spec measure(GenServer.server()) :: {:ok, Measurement.t()} | {:error, any()}
  def measure(server) do
    GenServer.call(server, :measure)
  end

  @deprecated "Use BMP280.measure/1 instead"
  def read(server), do: measure(server)

  @doc """
  Update the sea level pressure estimate

  The sea level pressure should be specified in Pascals. The estimate
  is used for altitude calculations.
  """
  @spec update_sea_level_pressure(GenServer.server(), number()) :: :ok
  def update_sea_level_pressure(server, new_estimate) do
    GenServer.call(server, {:update_sea_level, new_estimate})
  end

  @doc """
  Force the altitude to a known value

  Altitude calculations depend on the accuracy of the sea level pressure estimate. Since
  the sea level pressure changes based on the weather, it needs to be kept up to date
  or altitude measurements can be pretty far off. Another way to set the sea level pressure
  is to report a known altitude. Call this function with the current altitude in meters.

  This function returns an error if the attempt to sample the current barometric
  pressure fails.
  """
  @spec force_altitude(GenServer.server(), number()) :: :ok | {:error, any()}
  def force_altitude(server, altitude_m) do
    GenServer.call(server, {:force_altitude, altitude_m})
  end

  @doc """
  Detect the type of sensor that is located at the I2C address

  If the sensor is a known BMP280 or BME280 the response will either contain
  `:bmp280` or `:bme280`. If the sensor does not report back that it is one of
  those two types of sensors the return value will contain the id value that
  was reported back form the sensor.

  The bus address is likely going to be 0x77 (the default) or 0x76.
  """
  @spec detect(String.t(), 0x76 | 0x77) :: {:ok, sensor_type()} | {:error, any()}
  def detect(bus_name, bus_address \\ @default_bmp280_bus_address) do
    with {:ok, transport} <- Transport.open(bus_name, bus_address) do
      Comm.sensor_type(transport)
    end
  end

  @impl GenServer
  def init(args) do
    bus_name = Keyword.get(args, :bus_name, "i2c-1")
    bus_address = Keyword.get(args, :bus_address, @default_bmp280_bus_address)

    Logger.info(
      "[BMP280] Starting on bus #{bus_name} at address #{inspect(bus_address, base: :hex)}"
    )

    with {:ok, transport} <- Transport.open(bus_name, bus_address),
         {:ok, sensor_type} <- Comm.sensor_type(transport) do
      state = %{
        transport: transport,
        calibration: nil,
        sea_level_pa: Keyword.get(args, :sea_level_pa, @sea_level_pa),
        sensor_type: sensor_type,
        last_measurement: nil
      }

      {:ok, state, {:continue, :init_sensor}}
    else
      _error ->
        {:stop, :device_not_found}
    end
  end

  @impl GenServer
  def handle_continue(:init_sensor, state) do
    Logger.info("[BMP280] Initializing sensor type #{state.sensor_type}")

    new_state =
      state
      |> init_sensor()
      |> read_and_put_new_measurement()

    schedule_measurement()

    {:noreply, new_state}
  end

  @impl GenServer
  def handle_call(:measure, _from, state) do
    if state.last_measurement do
      {:reply, {:ok, state.last_measurement}, state}
    else
      {:reply, {:error, :no_measurement}, state}
    end
  end

  def handle_call(:sensor_type, _from, state) do
    {:reply, state.sensor_type, state}
  end

  def handle_call({:update_sea_level, new_estimate}, _from, state) do
    {:reply, :ok, %{state | sea_level_pa: new_estimate}}
  end

  def handle_call({:force_altitude, altitude_m}, _from, state) do
    if state.last_measurement do
      sea_level = Calc.sea_level_pressure(state.last_measurement.pressure_pa, altitude_m)
      {:reply, :ok, %{state | sea_level_pa: sea_level}}
    else
      {:reply, {:error, :no_measurement}, state}
    end
  end

  @impl GenServer
  def handle_info(:schedule_measurement, state) do
    schedule_measurement()
    {:noreply, read_and_put_new_measurement(state)}
  end

  defp schedule_measurement() do
    Process.send_after(self(), :schedule_measurement, @polling_interval)
  end

  defp init_sensor(state) do
    sensor_module(state.sensor_type).init(state)
  end

  defp read_sensor(state) do
    sensor_module(state.sensor_type).read(state)
  end

  defp read_and_put_new_measurement(state) do
    case read_sensor(state) do
      {:ok, measurement} ->
        %{state | last_measurement: measurement}

      {:error, reason} ->
        Logger.error("[BMP280] Error reading measurement: #{inspect(reason)}")
        state
    end
  end

  defp sensor_module(:bmp180), do: BMP280.BMP180Sensor
  defp sensor_module(:bmp280), do: BMP280.BMP280Sensor
  defp sensor_module(:bme280), do: BMP280.BME280Sensor
  defp sensor_module(:bme680), do: BMP280.BME680Sensor
end
