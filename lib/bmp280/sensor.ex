defmodule BMP280.Sensor do
  @moduledoc false

  @type t :: %{
          calibration:
            BMP280.BMP180Calibration.t()
            | BMP280.BMP280Calibration.t()
            | BMP280.BME280Calibration.t()
            | BMP280.BME680Calibration.t(),
          init_fn: fun(),
          last_measurement: BMP280.Measurement.t(),
          read_fn: fun(),
          sea_level_pa: number(),
          sensor_type: BMP280.sensor_type(),
          transport: BMP280.Transport.t()
        }

  @callback init(BMP280.Sensor.t()) :: BMP280.Sensor.t()

  @callback read(BMP280.Sensor.t()) :: {:ok, BMP280.Measurement.t()} | {:error, any}

  defstruct [
    :calibration,
    :init_fn,
    :last_measurement,
    :read_fn,
    :sea_level_pa,
    :sensor_type,
    :transport
  ]

  @doc """
  Creates an appropriate sensor struct based on the provided options.
  """
  def new(opts) do
    sensor_type = Access.fetch!(opts, :sensor_type)
    sea_level_pa = Access.fetch!(opts, :sea_level_pa)
    transport = Access.fetch!(opts, :transport)
    mod = sensor_mod(sensor_type)

    %__MODULE__{
      calibration: nil,
      init_fn: fn state -> mod.init_fn(state) end,
      last_measurement: nil,
      read_fn: fn state -> make_read_fn(mod, state) end,
      sea_level_pa: sea_level_pa,
      sensor_type: sensor_type,
      transport: transport
    }
  end

  defp make_read_fn(mod, state) do
    case mod.read(state) do
      {:ok, measurement} ->
        struct(state, last_measurement: measurement)

      {:error, reason} ->
        require Logger
        Logger.error("[BMP280] Error reading measurement: #{inspect(reason)}")
        state
    end
  end

  defp sensor_mod(sensor_type) do
    sensor_type = sensor_type |> Atom.to_string() |> String.upcase()
    String.to_existing_atom("Elixir.BMP280.#{sensor_type}Sensor")
  end
end
