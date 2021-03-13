defmodule BMP280.BMP280CalibrationTest do
  use ExUnit.Case
  alias BMP280.BMP280Calibration
  doctest BMP280.BMP280Calibration

  test "parse bmp280 1 calibration" do
    raw_calibration =
      <<29, 110, 173, 102, 50, 0, 27, 143, 56, 214, 208, 11, 84, 43, 15, 255, 249, 255, 12, 48,
        32, 209, 136, 19>>

    assert BMP280Calibration.from_binary(raw_calibration) ==
             %{
               type: :bmp280,
               dig_P1: 36635,
               dig_P2: -10696,
               dig_P3: 3024,
               dig_P4: 11092,
               dig_P5: -241,
               dig_P6: -7,
               dig_P7: 12300,
               dig_P8: -12000,
               dig_P9: 5000,
               dig_T1: 28189,
               dig_T2: 26285,
               dig_T3: 50
             }
  end
end
