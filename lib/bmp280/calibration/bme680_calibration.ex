defmodule BMP280.BME680Calibration do
  @moduledoc false

  @type t() :: %{
          type: :bme680,
          par_t1: integer,
          par_t2: integer,
          par_t3: integer,
          par_p1: integer,
          par_p2: integer,
          par_p3: integer,
          par_p4: integer,
          par_p5: integer,
          par_p6: byte,
          par_p7: integer,
          par_p8: integer,
          par_p9: integer,
          par_p10: integer,
          par_h1: integer,
          par_h2: integer,
          par_h3: integer,
          par_h4: integer,
          par_h5: integer,
          par_h6: integer,
          par_h7: integer,
          par_gh1: integer,
          par_gh2: integer,
          par_gh3: integer,
          range_switching_error: integer,
          res_heat_range: 0..3,
          res_heat_val: integer
        }

  @spec from_binary({<<_::184>>, <<_::112>>, <<_::40>>}) :: t()
  def from_binary({
        <<par_t2::little-signed-16, par_t3::signed, _skip8D, par_p1::little-16,
          par_p2::little-signed-16, par_p3::signed, _skip93, par_p4::little-signed-16,
          par_p5::little-signed-16, par_p7::signed, par_p6::signed, _skip9A, _skip9B,
          par_p8::little-signed-16, par_p9::little-signed-16, par_p10>>,
        <<par_h2h, par_h2l::4, par_h1l::4, par_h1h, par_h3::signed, par_h4::signed,
          par_h5::signed, par_h6, par_h7::signed, par_t1::little-16, par_gh2::little-signed-16,
          par_gh1::signed, par_gh3::signed>>,
        <<res_heat_val::signed, _skip01, _::2, res_heat_range::2, _::4, _skip03,
          range_switching_error::signed-4, _::4>>
      }) do
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
      range_switching_error: range_switching_error,
      res_heat_range: res_heat_range,
      res_heat_val: res_heat_val
    }
  end

  @spec raw_to_temperature(t(), integer()) :: float()
  def raw_to_temperature(cal, raw_temp) do
    var1 = (raw_temp / 16_384 - cal.par_t1 / 1024) * cal.par_t2

    var2 =
      (raw_temp / 131_072 - cal.par_t1 / 8192) * (raw_temp / 131_072 - cal.par_t1 / 8192) *
        cal.par_t3 * 16

    (var1 + var2) / 5120
  end

  @spec raw_to_pressure(t(), number(), integer()) :: float()
  def raw_to_pressure(cal, temp, raw_pressure) do
    t_fine = temp * 5120

    var1 = t_fine / 2 - 64_000
    var2 = var1 * var1 * cal.par_p6 / 131_072
    var2 = var2 + var1 * cal.par_p5 * 2
    var2 = var2 / 4 + cal.par_p4 * 65_536
    var1 = (cal.par_p3 * var1 * var1 / 16_384 + cal.par_p2 * var1) / 524_288
    var1 = (1 + var1 / 32_768) * cal.par_p1
    press_comp = 1_048_576 - raw_pressure
    press_comp = (press_comp - var2 / 4096) * 6250 / var1
    var1 = cal.par_p9 * press_comp * press_comp / 2_147_483_648
    var2 = press_comp * cal.par_p8 / 32_768
    var3 = press_comp / 256 * press_comp / 256 * press_comp / 256 * cal.par_p10 / 131_072

    press_comp + (var1 + var2 + var3 + cal.par_p7 * 128) / 16
  end

  @spec raw_to_humidity(t(), number(), integer()) :: float()
  def raw_to_humidity(cal, temp, hum_adc) do
    var1 = hum_adc - (cal.par_h1 * 16 + cal.par_h3 / 2 * temp)

    var2 =
      var1 *
        (cal.par_h2 / 262_144 *
           (1 +
              cal.par_h4 / 16_384 *
                temp + cal.par_h5 / 1_048_576 * temp * temp))

    var3 = cal.par_h6 / 16_384
    var4 = cal.par_h7 / 2_097_152
    h = var2 + (var3 + var4 * temp) * var2 * var2

    min(100, max(0, h))
  end

  @gas_range_lookup1 {
    2_147_483_647.0,
    2_147_483_647.0,
    2_147_483_647.0,
    2_147_483_647.0,
    2_147_483_647.0,
    2_126_008_810.0,
    2_147_483_647.0,
    2_130_303_777.0,
    2_147_483_647.0,
    2_147_483_647.0,
    2_143_188_679.0,
    2_136_746_228.0,
    2_147_483_647.0,
    2_126_008_810.0,
    2_147_483_647.0,
    2_147_483_647.0
  }

  @gas_range_lookup2 {
    4_096_000_000.0,
    2_048_000_000.0,
    1_024_000_000.0,
    512_000_000.0,
    255_744_255.0,
    127_110_228.0,
    64_000_000.0,
    32_258_064.0,
    16_016_016.0,
    8_000_000.0,
    4_000_000.0,
    2_000_000.0,
    1_000_000.0,
    500_000.0,
    250_000.0,
    125_000.0
  }

  @spec raw_to_gas_resistance(t(), integer(), integer()) :: float()
  def raw_to_gas_resistance(cal, gas_r, gas_range_r)
      when is_number(gas_r) and is_number(gas_range_r) do
    var1 = (1340 + 5 * cal.range_switching_error) * elem(@gas_range_lookup1, gas_range_r) / 65_536

    var2 = gas_r * 32_768 - 16_777_216 + var1
    var3 = elem(@gas_range_lookup2, gas_range_r) * var1 / 512
    (var3 + var2 / 2) / var2
  end
end
