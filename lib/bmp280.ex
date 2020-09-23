defmodule BMP280 do
  use GenServer

  alias BMP280.{Calc, Calibration, Comm, Measurement, Transport}
  @sea_level_pa 100_000

  @typedoc """
  The type of sensor in use.
  """
  @type sensor_type() :: :bmp280 | :bme280 | 0..255

  @moduledoc """
  Read temperature and pressure measurements from a [Bosch
  BMP280](https://www.bosch-sensortec.com/products/environmental-sensors/pressure-sensors/pressure-sensors-bmp280-1.html)
  sensor in Elixir.
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
          bus_address: Circuits.I2C.address(),
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
  Read the current temperature, pressure, altitude

  An error is return if the I2C transactions fail.
  """
  @spec read(GenServer.server()) :: {:ok, Measurement.t()} | {:error, any()}
  def read(server) do
    GenServer.call(server, :read)
  end

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

  @impl GenServer
  def init(args) do
    bus_name = Keyword.get(args, :bus_name, "i2c-1")
    bus_address = Keyword.get(args, :bus_address, 0x77)

    {:ok, transport} = Transport.open(bus_name, bus_address)

    state = %{
      transport: transport,
      calibration: nil,
      sea_level_pa: Keyword.get(args, :sea_level_pa, @sea_level_pa),
      sensor_type: nil
    }

    {:ok, state, {:continue, :continue}}
  end

  @impl GenServer
  def handle_continue(:continue, state) do
    new_state =
      state
      |> query_sensor()
      |> send_enable()
      |> read_calibration()

    {:noreply, new_state}
  end

  @impl GenServer
  def handle_call(:read, _from, state) do
    rc =
      case Comm.read_raw_samples(state.transport) do
        {:ok, raw_pressure, raw_temperature} ->
          {:ok,
           Calc.raw_to_measurement(
             state.calibration,
             state.sea_level_pa,
             raw_temperature,
             raw_pressure
           )}

        error ->
          error
      end

    {:reply, rc, state}
  end

  def handle_call(:sensor_type, _from, state) do
    {:reply, state.sensor_type, state}
  end

  def handle_call({:update_sea_level, new_estimate}, _from, state) do
    {:reply, :ok, %{state | sea_level_pa: new_estimate}}
  end

  def handle_call({:force_altitude, altitude_m}, _from, state) do
    case Comm.read_raw_samples(state.transport) do
      {:ok, raw_pressure, raw_temperature} ->
        {:ok,
         m =
           Calc.raw_to_measurement(
             state.calibration,
             state.sea_level_pa,
             raw_temperature,
             raw_pressure
           )}

        sea_level = Calc.sea_level_pressure(m.pressure_pa, altitude_m)

        {:reply, :ok, %{state | sea_level_pa: sea_level}}

      error ->
        {:reply, error, state}
    end
  end

  defp query_sensor(state) do
    {:ok, sensor_type} = Comm.sensor_type(state.transport)

    %{state | sensor_type: sensor_type}
  end

  defp send_enable(state) do
    :ok = Comm.send_enable(state.transport)

    state
  end

  defp read_calibration(state) do
    {:ok, raw} = Comm.read_calibration(state.transport)

    %{state | calibration: Calibration.from_binary(raw)}
  end
end
