defmodule BMP280.Sensor do
  @moduledoc false

  @callback init(BMP280.state()) :: BMP280.state()

  @callback read(BMP280.state()) :: {:ok, BMP280.Measurement.t()} | {:error, any}
end
