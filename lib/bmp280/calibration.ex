defmodule BMP280.Calibration do
  @moduledoc false

  @type uint16() :: 0..65535
  @type int16() :: -32768..32767
  @type uint8() :: 0..255
  @type int8() :: -128..127
  @type int12() :: -2048..2047

  @type t() :: %{type: BMP280.sensor_type()}

  @spec from_binary(BMP280.sensor_type(), <<_::192>> | <<_::248>>) :: BMP280.Calibration.t()
  def from_binary(
        :bmp280,
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

  def from_binary(
        :bme280,
        <<dig_T1::little-16, dig_T2::little-signed-16, dig_T3::little-signed-16,
          dig_P1::little-16, dig_P2::little-signed-16, dig_P3::little-signed-16,
          dig_P4::little-signed-16, dig_P5::little-signed-16, dig_P6::little-signed-16,
          dig_P7::little-signed-16, dig_P8::little-signed-16, dig_P9::little-signed-16, _, dig_H1,
          dig_H2::little-signed-16, dig_H3, dig_H4h, dig_H4l::4, dig_H5l::4, dig_H5h,
          dig_H6::signed>>
      ) do
    %{
      type: :bme280,
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
      dig_P9: dig_P9,
      dig_H1: dig_H1,
      dig_H2: dig_H2,
      dig_H3: dig_H3,
      dig_H4: dig_H4h * 16 + dig_H4l,
      dig_H5: dig_H5h * 16 + dig_H5l,
      dig_H6: dig_H6
    }
  end

  def from_binary(
        :bme680,
        {range_switching_error,
         <<par_t2::little-signed-16, par_t3::signed, _skip8D, par_p1::little-16,
           par_p2::little-signed-16, par_p3::signed, _skip93, par_p4::little-signed-16,
           par_p5::little-signed-16, par_p7::signed, par_p6::signed, _skip9A, _skip9B,
           par_p8::little-signed-16, par_p9::little-signed-16, par_p10>>,
         <<par_h2h, par_h2l::4, par_h1l::4, par_h1h, par_h3::signed, par_h4::signed,
           par_h5::signed, par_h6, par_h7::signed, par_t1::little-16, par_gh2::little-signed-16,
           par_gh1::signed, par_gh3::signed>>}
      ) do
    %{
      type: :bme680,
      par_t1: par_t1,
      par_t2: par_t2,
      par_t3: par_t3,
      par_p1: par_p1,
      par_p2: par_p2,
      par_p3: par_p3,
      par_p4: par_p4,
      par_p5: par_p5,
      par_p6: par_p6,
      par_p7: par_p7,
      par_p8: par_p8,
      par_p9: par_p9,
      par_p10: par_p10,
      par_h1: par_h1h * 16 + par_h1l,
      par_h2: par_h2h * 16 + par_h2l,
      par_h3: par_h3,
      par_h4: par_h4,
      par_h5: par_h5,
      par_h6: par_h6,
      par_h7: par_h7,
      par_gh1: par_gh1,
      par_gh2: par_gh2,
      par_gh3: par_gh3,
      range_switching_error: range_switching_error
    }
  end

  @spec raw_to_temperature(t(), integer()) :: float()
  def raw_to_temperature(%{type: :bme680} = cal, raw_temp) do
    var1 = (raw_temp / 16384 - cal.par_t1 / 1024) * cal.par_t2

    var2 =
      (raw_temp / 131_072 - cal.par_t1 / 8192) * (raw_temp / 131_072 - cal.par_t1 / 8192) *
        cal.par_t3 * 16

    (var1 + var2) / 5120
  end

  def raw_to_temperature(%{type: sensor} = cal, raw_temp) when sensor in [:bme280, :bmp280] do
    var1 = (raw_temp / 16384 - cal.dig_T1 / 1024) * cal.dig_T2

    var2 =
      (raw_temp / 131_072 - cal.dig_T1 / 8192) * (raw_temp / 131_072 - cal.dig_T1 / 8192) *
        cal.dig_T3

    (var1 + var2) / 5120
  end

  @spec raw_to_pressure(t(), number(), integer()) :: float()
  def raw_to_pressure(%{type: :bme680} = cal, temp, raw_pressure) do
    t_fine = temp * 5120

    var1 = t_fine / 2 - 64000
    var2 = var1 * var1 * cal.par_p6 / 131_072
    var2 = var2 + var1 * cal.par_p5 * 2
    var2 = var2 / 4 + cal.par_p4 * 65536
    var1 = (cal.par_p3 * var1 * var1 / 16384 + cal.par_p2 * var1) / 524_288
    var1 = (1 + var1 / 32768) * cal.par_p1
    press_comp = 1_048_576 - raw_pressure
    press_comp = (press_comp - var2 / 4096) * 6250 / var1
    var1 = cal.par_p9 * press_comp * press_comp / 2_147_483_648
    var2 = press_comp * cal.par_p8 / 32768
    var3 = press_comp / 256 * press_comp / 256 * press_comp / 256 * cal.par_p10 / 131_072

    press_comp + (var1 + var2 + var3 + cal.par_p7 * 128) / 16
  end

  def raw_to_pressure(%{type: sensor} = cal, temp, raw_pressure)
      when sensor in [:bme280, :bmp280] do
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

  @spec raw_to_humidity(t(), number(), integer()) :: float() | :unknown
  def raw_to_humidity(%{type: :bme280} = cal, temp, raw_humidity)
      when is_integer(raw_humidity) do
    t_fine = temp * 5120
    var_H = t_fine - 76800

    var_H =
      (raw_humidity - (cal.dig_H4 * 64 + cal.dig_H5 / 16384 * var_H)) *
        (cal.dig_H2 / 65536 *
           (1 +
              cal.dig_H6 / 67_108_864 * var_H *
                (1 + cal.dig_H3 / 67_108_864 * var_H)))

    var_H = var_H * (1 - cal.dig_H1 * var_H / 524_288)

    min(100, max(0, var_H))
  end

  def raw_to_humidity(%{type: :bme680} = cal, temp, hum_adc) when is_integer(hum_adc) do
    var1 = hum_adc - (cal.par_h1 * 16 + cal.par_h3 / 2 * temp)

    var2 =
      var1 *
        (cal.par_h2 / 262_144 *
           (1 +
              cal.par_h4 / 16384 *
                temp + cal.par_h5 / 1_048_576 * temp * temp))

    var3 = cal.par_h6 / 16384
    var4 = cal.par_h7 / 2_097_152
    h = var2 + (var3 + var4 * temp) * var2 * var2

    min(100, max(0, h))
  end

  def raw_to_humidity(_cal, _temp, _raw), do: :unknown
end
