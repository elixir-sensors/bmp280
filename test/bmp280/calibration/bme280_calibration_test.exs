defmodule BMP280.BME280CalibrationTest do
  use ExUnit.Case
  alias BMP280.BME280Calibration
  doctest BMP280.BME280Calibration

  test "parse bme280 1 calibration" do
    raw_calibration =
      <<29, 110, 173, 102, 50, 0, 27, 143, 56, 214, 208, 11, 84, 43, 15, 255, 249, 255, 12, 48,
        32, 209, 136, 19, 0, 75, 82, 1, 0, 23, 44, 3, 30>>

    assert BME280Calibration.from_binary(raw_calibration) ==
             %{
               type: :bme280,
               dig_h1: 75,
               dig_h2: 338,
               dig_h3: 0,
               dig_h4: 370,
               dig_h5: 60,
               dig_h6: 30,
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

  test "parse bme280 2 calibration" do
    raw_calibration =
      <<137, 110, 105, 104, 50, 0, 69, 145, 172, 214, 208, 11, 201, 31, 169, 255, 249, 255, 172,
        38, 10, 216, 189, 16, 0, 75, 138, 1, 0, 15, 40, 3, 30>>

    assert BME280Calibration.from_binary(raw_calibration) ==
             %{
               type: :bme280,
               dig_h1: 75,
               dig_h2: 394,
               dig_h3: 0,
               dig_h4: 242,
               dig_h5: 56,
               dig_h6: 30,
               dig_p1: 37_189,
               dig_p2: -10_580,
               dig_p3: 3024,
               dig_p4: 8137,
               dig_p5: -87,
               dig_p6: -7,
               dig_p7: 9900,
               dig_p8: -10_230,
               dig_p9: 4285,
               dig_t1: 28_297,
               dig_t2: 26_729,
               dig_t3: 50
             }
  end
end
