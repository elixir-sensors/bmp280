defmodule BMP280.BME280Calibration do
  @moduledoc false

  @type t() :: %{
          type: :bme280,
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
          dig_p9: integer,
          dig_h1: byte,
          dig_h2: integer,
          dig_h3: byte,
          dig_h4: non_neg_integer,
          dig_h5: non_neg_integer,
          dig_h6: integer
        }

  @spec from_binary(<<_::264>>) :: t()
  def from_binary(
        <<dig_t1::little-16, dig_t2::little-signed-16, dig_t3::little-signed-16,
          dig_p1::little-16, dig_p2::little-signed-16, dig_p3::little-signed-16,
          dig_p4::little-signed-16, dig_p5::little-signed-16, dig_p6::little-signed-16,
          dig_p7::little-signed-16, dig_p8::little-signed-16, dig_p9::little-signed-16, _, dig_h1,
          dig_h2::little-signed-16, dig_h3, dig_h4h, dig_h4l::4, dig_h5l::4, dig_h5h,
          dig_h6::signed>>
      ) do
    %{
      type: :bme280,
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
      dig_p9: dig_p9,
      dig_h1: dig_h1,
      dig_h2: dig_h2,
      dig_h3: dig_h3,
      dig_h4: dig_h4h * 16 + dig_h4l,
      dig_h5: dig_h5h * 16 + dig_h5l,
      dig_h6: dig_h6
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

  @spec raw_to_humidity(t(), number(), integer()) :: float()
  def raw_to_humidity(cal, temp, raw_humidity) do
    t_fine = temp * 5120
    var_h = t_fine - 76_800

    var_h =
      (raw_humidity - (cal.dig_h4 * 64 + cal.dig_h5 / 16_384 * var_h)) *
        (cal.dig_h2 / 65_536 *
           (1 +
              cal.dig_h6 / 67_108_864 * var_h *
                (1 + cal.dig_h3 / 67_108_864 * var_h)))

    var_h = var_h * (1 - cal.dig_h1 * var_h / 524_288)

    min(100, max(0, var_h))
  end
end
