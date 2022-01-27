defmodule BMP280.Sensor do
  @moduledoc false

  defstruct ~w[calibration last_measurement sea_level_pa sensor_type transport]a

  @type t :: %{
          calibration:
            BMP280.BMP180Calibration.t()
            | BMP280.BMP280Calibration.t()
            | BMP280.BME280Calibration.t()
            | BMP280.BME680Calibration.t(),
          last_measurement: BMP280.Measurement.t(),
          sea_level_pa: number(),
          sensor_type: BMP280.sensor_type(),
          transport: BMP280.Transport.t()
        }

  @callback init(BMP280.Sensor.t()) :: BMP280.Sensor.t()

  @callback read(BMP280.Sensor.t()) :: {:ok, BMP280.Measurement.t()} | {:error, any}

  def new(opts) do
    %__MODULE__{
      transport: Access.fetch!(opts, :transport),
      sea_level_pa: Access.fetch!(opts, :sea_level_pa),
      sensor_type: Access.fetch!(opts, :sensor_type)
    }
  end

  def init(state), do: sensor_mod(state.sensor_type).init(state)

  def read(state), do: sensor_mod(state.sensor_type).read(state)

  defp sensor_mod(sensor_type) do
    sensor_type = sensor_type |> Atom.to_string() |> String.upcase()
    String.to_existing_atom("Elixir.BMP280.#{sensor_type}Sensor")
  end
end
