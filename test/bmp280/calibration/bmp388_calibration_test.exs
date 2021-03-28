defmodule BMP280.BMP388CalibrationTest do
  use ExUnit.Case
  alias BMP280.BMP388Calibration
  doctest BMP280.BMP388Calibration

  test "parse calibration" do
    # TODO: use real value
    raw_calibration =
      <<29, 110, 173, 102, 50, 0, 27, 143, 56, 214, 208, 11, 84, 43, 15, 255, 249, 255, 12, 48,
        32>>

    assert BMP388Calibration.from_binary(raw_calibration) == %{
             type: :bmp388,
             par_t1: 7534,
             par_t2: 44390,
             par_t3: 50,
             par_p1: 27,
             par_p2: -28872,
             par_p3: -42,
             par_p4: -48,
             par_p5: 2900,
             par_p6: 11023,
             par_p7: -1,
             par_p8: -7,
             par_p9: -244,
             par_p10: 48,
             par_p11: 32
           }
  end
end
