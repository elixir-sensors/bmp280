defprotocol BMP2XX.Sensor do
  @type t :: %{
          calibration: map,
          sea_level_pa: number(),
          transport: BMP2XX.Transport.t()
        }

  @doc "Initializes a sensor"
  @spec init(keyword() | map()) :: t()
  def init(state)

  @doc "Reads one measurement from a sensor"
  @spec read(t()) :: {:ok, BMP2XX.Measurement.t()} | {:error, any()}
  def read(state)
end
