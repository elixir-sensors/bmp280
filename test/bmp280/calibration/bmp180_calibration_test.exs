defmodule BMP280.BMP180CalibrationTest do
  use ExUnit.Case
  alias BMP280.BMP180Calibration
  doctest BMP280.BMP180Calibration

  test "parse bme280 1 calibration" do
    raw_calibration =
      <<25, 38, 251, 185, 200, 200, 133, 213, 100, 76, 63, 129, 25, 115, 0, 40, 128, 0, 209, 246,
        9, 104>>

    assert BMP180Calibration.from_binary(raw_calibration) ==
             %{
               ac1: 6438,
               ac2: -1095,
               ac3: -14136,
               ac4: 34261,
               ac5: 25676,
               ac6: 16257,
               b1: 6515,
               b2: 40,
               mb: -32768,
               mc: -11786,
               md: 2408,
               type: :bmp180
             }
  end
end
