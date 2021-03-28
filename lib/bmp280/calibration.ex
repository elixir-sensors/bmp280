defmodule BMP280.Calibration do
  @moduledoc false

  @type t ::
          BMP280.BMP280Calibration.t()
          | BMP280.BME280Calibration.t()
          | BMP280.BME680Calibration.t()
          | BMP280.BMP388Calibration.t()
end
