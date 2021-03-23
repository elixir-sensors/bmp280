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
               dig_H1: 75,
               dig_H2: 338,
               dig_H3: 0,
               dig_H4: 370,
               dig_H5: 60,
               dig_H6: 30,
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

  test "parse bme280 2 calibration" do
    raw_calibration =
      <<137, 110, 105, 104, 50, 0, 69, 145, 172, 214, 208, 11, 201, 31, 169, 255, 249, 255, 172,
        38, 10, 216, 189, 16, 0, 75, 138, 1, 0, 15, 40, 3, 30>>

    assert BME280Calibration.from_binary(raw_calibration) ==
             %{
               type: :bme280,
               dig_H1: 75,
               dig_H2: 394,
               dig_H3: 0,
               dig_H4: 242,
               dig_H5: 56,
               dig_H6: 30,
               dig_P1: 37189,
               dig_P2: -10580,
               dig_P3: 3024,
               dig_P4: 8137,
               dig_P5: -87,
               dig_P6: -7,
               dig_P7: 9900,
               dig_P8: -10230,
               dig_P9: 4285,
               dig_T1: 28297,
               dig_T2: 26729,
               dig_T3: 50
             }
  end
end
