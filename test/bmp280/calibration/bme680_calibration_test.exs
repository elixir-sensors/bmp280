defmodule BMP280.BME680CalibrationTest do
  use ExUnit.Case
  alias BMP280.BME680Calibration
  doctest BMP280.BME680Calibration

  test "parse bme680 calibration" do
    raw_calibration = {
      <<178, 102, 3, 16, 67, 138, 91, 215, 88, 0, 228, 18, 138, 255, 26, 30, 0, 0, 3, 253, 217,
        242, 30>>,
      <<63, 221, 44, 0, 45, 20, 120, 156, 83, 102, 175, 232, 226, 18>>,
      <<50, 170, 22, 74, 19>>
    }

    assert BME680Calibration.from_binary(raw_calibration) ==
             %{
               type: :bme680,
               par_t1: 26_195,
               par_t2: 26_290,
               par_t3: 3,
               par_p1: 35_395,
               par_p2: -10_405,
               par_p3: 88,
               par_p4: 4836,
               par_p5: -118,
               par_p6: 30,
               par_p7: 26,
               par_p8: -765,
               par_p9: -3367,
               par_p10: 30,
               par_h1: 717,
               par_h2: 1021,
               par_h3: 0,
               par_h4: 45,
               par_h5: 20,
               par_h6: 120,
               par_h7: -100,
               par_gh1: -30,
               par_gh2: -5969,
               par_gh3: 18,
               range_switching_error: 1,
               res_heat_val: 50,
               res_heat_range: 1
             }
  end
end
