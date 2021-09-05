defmodule BMP280.Sensor do
  @moduledoc false

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
end
