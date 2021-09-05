defmodule BMP280.BMP180CalibrationTest do
  use ExUnit.Case
  # alias BMP280.BMP180Calibration
  doctest BMP280.BMP180Calibration

  test "parse bme280 1 calibration" do
    raw_calibration =
      <<25, 38, 251, 185, 200, 200, 133, 213, 100, 76, 63, 129, 25, 115, 0, 40, 128, 0, 209, 246,
        9, 104>>

    # assert BMP180Calibration.from_binary(raw_calibration) ==
    assert from_binary(raw_calibration) ==
             %{
               type: :bmp180,
               ac1: 408,
               ac2: -72,
               ac3: -14383,
               ac4: 32741,
               ac5: 32757,
               ac6: 23153,
               b1: 6190,
               b2: 4,
               mb: -32768,
               mc: -8711,
               md: 2868
             }
  end

  def from_binary(
        <<ac1::little-16, ac2::little-16, ac3::little-16, ac4::little-unsigned-16,
          ac5::little-unsigned-16, ac6::little-unsigned-16, b1::little-16, b2::little-16,
          mb::little-16, mc::little-16, md::little-16>>
      ) do
    %{
      type: :bmp180,
      ac1: ac1,
      ac2: ac2,
      ac3: ac3,
      ac4: ac4,
      ac5: ac5,
      ac6: ac6,
      b1: b1,
      b2: b2,
      mb: mb,
      mc: mc,
      md: md
    }
  end
end
