defmodule BMP280.CalibrationTest do
  use ExUnit.Case
  alias BMP280.Calibration
  doctest BMP280.Calibration

  test "parse bmp280 1 calibration" do
    raw_calibration =
      <<29, 110, 173, 102, 50, 0, 27, 143, 56, 214, 208, 11, 84, 43, 15, 255, 249, 255, 12, 48,
        32, 209, 136, 19>>

    assert Calibration.from_binary(:bmp280, raw_calibration) ==
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

  test "parse bme280 1 calibration" do
    raw_calibration =
      <<29, 110, 173, 102, 50, 0, 27, 143, 56, 214, 208, 11, 84, 43, 15, 255, 249, 255, 12, 48,
        32, 209, 136, 19, 0, 75, 82, 1, 0, 23, 44, 3, 30>>

    assert Calibration.from_binary(:bme280, raw_calibration) ==
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

    assert Calibration.from_binary(:bme280, raw_calibration) ==
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

  test "parse bme680 calibration" do
    raw_calibration =
      {0, 1, 243,
       <<178, 102, 3, 16, 67, 138, 91, 215, 88, 0, 228, 18, 138, 255, 26, 30, 0, 0, 3, 253, 217,
         242, 30>>, <<63, 221, 44, 0, 45, 20, 120, 156, 83, 102, 175, 232, 226, 18>>}

    assert Calibration.from_binary(:bme680, raw_calibration) ==
             %{
               par_gh1: -30,
               par_gh2: -5969,
               par_gh3: 18,
               par_h1: 717,
               par_h2: 1021,
               par_h3: 0,
               par_h4: 45,
               par_h5: 20,
               par_h6: 120,
               par_h7: -100,
               par_p1: 35395,
               par_p10: 30,
               par_p2: -10405,
               par_p3: 88,
               par_p4: 4836,
               par_p5: -118,
               par_p6: 30,
               par_p7: 26,
               par_p8: -765,
               par_p9: -3367,
               par_t1: 26195,
               par_t2: 26290,
               par_t3: 3,
               res_heat_val: 0,
               res_heat_range: 1,
               range_switching_error: 243,
               type: :bme680
             }
  end
end
