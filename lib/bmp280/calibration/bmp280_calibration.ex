defmodule BMP280.BMP280Calibration do
  @moduledoc false

  @type t() :: %{
          type: :bmp280,
          dig_t1: char,
          dig_t2: integer,
          dig_t3: integer,
          dig_p1: char,
          dig_p2: integer,
          dig_p3: integer,
          dig_p4: integer,
          dig_p5: integer,
          dig_p6: integer,
          dig_p7: integer,
          dig_p8: integer,
          dig_p9: integer
        }

  @spec from_binary(<<_::192>>) :: t()
  def from_binary(
        <<dig_t1::little-16, dig_t2::little-signed-16, dig_t3::little-signed-16,
          dig_p1::little-16, dig_p2::little-signed-16, dig_p3::little-signed-16,
          dig_p4::little-signed-16, dig_p5::little-signed-16, dig_p6::little-signed-16,
          dig_p7::little-signed-16, dig_p8::little-signed-16, dig_p9::little-signed-16>>
      ) do
    %{
      type: :bmp280,
      dig_t1: dig_t1,
      dig_t2: dig_t2,
      dig_t3: dig_t3,
      dig_p1: dig_p1,
      dig_p2: dig_p2,
      dig_p3: dig_p3,
      dig_p4: dig_p4,
      dig_p5: dig_p5,
      dig_p6: dig_p6,
      dig_p7: dig_p7,
      dig_p8: dig_p8,
      dig_p9: dig_p9
    }
  end

  @spec raw_to_temperature(t(), integer()) :: float()
  def raw_to_temperature(cal, raw_temp) do
    var1 = (raw_temp / 16_384 - cal.dig_t1 / 1024) * cal.dig_t2

    var2 =
      (raw_temp / 131_072 - cal.dig_t1 / 8192) * (raw_temp / 131_072 - cal.dig_t1 / 8192) *
        cal.dig_t3

    (var1 + var2) / 5120
  end

  @spec raw_to_pressure(t(), number(), integer()) :: float()
  def raw_to_pressure(cal, temp, raw_pressure) do
    t_fine = temp * 5120

    var1 = t_fine / 2 - 64_000
    var2 = var1 * var1 * cal.dig_p6 / 32_768
    var2 = var2 + var1 * cal.dig_p5 * 2
    var2 = var2 / 4 + cal.dig_p4 * 65_536
    var1 = (cal.dig_p3 * var1 * var1 / 524_288 + cal.dig_p2 * var1) / 524_288
    var1 = (1 + var1 / 32_768) * cal.dig_p1
    p = 1_048_576 - raw_pressure
    p = (p - var2 / 4096) * 6250 / var1
    var1 = cal.dig_p9 * p * p / 2_147_483_648
    var2 = p * cal.dig_p8 / 32_768
    p = p + (var1 + var2 + cal.dig_p7) / 16

    p
  end
end
