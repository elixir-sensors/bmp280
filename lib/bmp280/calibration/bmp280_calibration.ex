defmodule BMP280.BMP280Calibration do
  @moduledoc false

  @type t() :: %{
          type: :bmp280,
          dig_T1: char,
          dig_T2: integer,
          dig_T3: integer,
          dig_P1: char,
          dig_P2: integer,
          dig_P3: integer,
          dig_P4: integer,
          dig_P5: integer,
          dig_P6: integer,
          dig_P7: integer,
          dig_P8: integer,
          dig_P9: integer
        }

  @spec from_binary(<<_::192>>) :: t()
  def from_binary(
        <<dig_T1::little-16, dig_T2::little-signed-16, dig_T3::little-signed-16,
          dig_P1::little-16, dig_P2::little-signed-16, dig_P3::little-signed-16,
          dig_P4::little-signed-16, dig_P5::little-signed-16, dig_P6::little-signed-16,
          dig_P7::little-signed-16, dig_P8::little-signed-16, dig_P9::little-signed-16>>
      ) do
    %{
      type: :bmp280,
      dig_T1: dig_T1,
      dig_T2: dig_T2,
      dig_T3: dig_T3,
      dig_P1: dig_P1,
      dig_P2: dig_P2,
      dig_P3: dig_P3,
      dig_P4: dig_P4,
      dig_P5: dig_P5,
      dig_P6: dig_P6,
      dig_P7: dig_P7,
      dig_P8: dig_P8,
      dig_P9: dig_P9
    }
  end

  @spec raw_to_temperature(t(), integer()) :: float()
  def raw_to_temperature(cal, raw_temp) do
    var1 = (raw_temp / 16384 - cal.dig_T1 / 1024) * cal.dig_T2

    var2 =
      (raw_temp / 131_072 - cal.dig_T1 / 8192) * (raw_temp / 131_072 - cal.dig_T1 / 8192) *
        cal.dig_T3

    (var1 + var2) / 5120
  end

  @spec raw_to_pressure(t(), number(), integer()) :: float()
  def raw_to_pressure(cal, temp, raw_pressure) do
    t_fine = temp * 5120

    var1 = t_fine / 2 - 64000
    var2 = var1 * var1 * cal.dig_P6 / 32768
    var2 = var2 + var1 * cal.dig_P5 * 2
    var2 = var2 / 4 + cal.dig_P4 * 65536
    var1 = (cal.dig_P3 * var1 * var1 / 524_288 + cal.dig_P2 * var1) / 524_288
    var1 = (1 + var1 / 32768) * cal.dig_P1
    p = 1_048_576 - raw_pressure
    p = (p - var2 / 4096) * 6250 / var1
    var1 = cal.dig_P9 * p * p / 2_147_483_648
    var2 = p * cal.dig_P8 / 32768
    p = p + (var1 + var2 + cal.dig_P7) / 16

    p
  end
end
