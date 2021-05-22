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
               dig_p1: 36_635,
               dig_p2: -10_696,
               dig_p3: 3024,
               dig_p4: 11_092,
               dig_p5: -241,
               dig_p6: -7,
               dig_p7: 12_300,
               dig_p8: -12_000,
               dig_p9: 5000,
               dig_t1: 28_189,
               dig_t2: 26_285,
               dig_t3: 50
             }
  end
end
