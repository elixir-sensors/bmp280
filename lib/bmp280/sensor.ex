defprotocol BMP280.Sensor do
  @type t :: %{
          calibration:
            BMP280.BMP180Calibration.t()
            | BMP280.BMP280Calibration.t()
            | BMP280.BME280Calibration.t()
            | BMP280.BME680Calibration.t(),
          sea_level_pa: number(),
          sensor_type: BMP280.sensor_type(),
          transport: BMP280.Transport.t()
        }

  @doc "Initializes a sensor"
  @spec init(keyword() | map()) :: t()
  def init(state)

  @doc "Reads one measurement from a sensor"
  @spec read(t()) :: {:ok, BMP280.Measurement.t()} | {:error, any()}
  def read(state)
end
