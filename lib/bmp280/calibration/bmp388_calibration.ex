defmodule BMP280.BMP388Calibration do
  @moduledoc false

  @type t() :: %{
          :type => :bmp388,
          :par_t1 => char(),
          :par_t2 => char(),
          :par_t3 => integer(),
          :par_p1 => integer(),
          :par_p2 => integer(),
          :par_p3 => integer(),
          :par_p4 => integer(),
          :par_p5 => char(),
          :par_p6 => char(),
          :par_p7 => integer(),
          :par_p8 => integer(),
          :par_p9 => integer(),
          :par_p10 => integer(),
          :par_p11 => integer()
        }

  @spec from_binary(<<_::168>>) :: t()
  def from_binary(<<
        par_t1_l,
        par_t1_h,
        par_t2_l,
        par_t2_h,
        par_t3::little-signed,
        par_p1_l,
        par_p1_h,
        par_p2_l,
        par_p2_h,
        par_p3::little-signed,
        par_p4::little-signed,
        par_p5_l,
        par_p5_h,
        par_p6_l,
        par_p6_h,
        par_p7::little-signed,
        par_p8::little-signed,
        par_p9_l,
        par_p9_h,
        par_p10::little-signed,
        par_p11::little-signed
      >>) do
    <<par_t1::little-16>> = <<par_t1_h, par_t1_l>>
    <<par_t2::little-16>> = <<par_t2_h, par_t2_l>>
    <<par_p1::little-signed-16>> = <<par_p1_h, par_p1_l>>
    <<par_p2::little-signed-16>> = <<par_p2_h, par_p2_l>>
    <<par_p5::little-16>> = <<par_p5_h, par_p5_l>>
    <<par_p6::little-16>> = <<par_p6_h, par_p6_l>>
    <<par_p9::little-signed-16>> = <<par_p9_h, par_p9_l>>

    %{
      type: :bmp388,
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
      par_p11: par_p11
    }
  end

  @doc """
  Calculate the temperature in Celsius.
  """
  @spec temperature_and_pressure_from_raw_samples(t(), BMP280.BMP388Sensor.raw_samples()) ::
          %{temperature_c: number, pressure_pa: number}
  def temperature_and_pressure_from_raw_samples(cal, raw_samles) do
    %{raw_temperature: raw_temperature, raw_pressure: raw_pressure} = raw_samles

    t_lin =
      with var1 <- raw_temperature - 256 * cal.par_t1,
           var2 <- cal.par_t2 * var1,
           var3 <- var1 * var1,
           var4 <- var3 * cal.par_t3,
           var5 <- var2 * 262_144 + var4,
           do: var5 / 4_294_967_296

    temperature_c = t_lin * 25 / 16384 / 100
    pressure_pa = raw_to_pressure_pa(cal, raw_pressure, t_lin)

    %{temperature_c: temperature_c, pressure_pa: pressure_pa}
  end

  @doc """
  Calculate the pressure in Pascal.
  """
  @spec raw_to_pressure_pa(t(), number(), number()) :: float()
  def raw_to_pressure_pa(cal, raw_pressure, t_lin) do
    offset =
      with var1 <- t_lin * t_lin,
           var2 <- var1 / 64,
           var3 <- var2 * t_lin / 256,
           var4 <- cal.par_p8 * var3 / 32,
           var5 <- cal.par_p7 * var1 * 16,
           var6 <- cal.par_p6 * t_lin * 4_194_304,
           do: cal.par_p5 * 140_737_488_355_328 + var4 + var5 + var6

    sensitivity =
      with var1 <- t_lin * t_lin,
           var2 <- var1 / 64,
           var3 <- var2 * t_lin / 256,
           var4 <- cal.par_p4 * var3 / 32,
           var5 <- cal.par_p3 * var1 * 4,
           var6 <- (cal.par_p2 - 16384) * t_lin * 2_097_152,
           do: (cal.par_p1 - 16384) * 70_368_744_177_664 + var4 + var5 + var6

    var1 = sensitivity / 16_777_216 * raw_pressure
    var2 = cal.par_p10 * t_lin
    var3 = var2 + 65536 * cal.par_p9
    var4 = var3 * raw_pressure / 8192
    var5 = raw_pressure * (var4 / 10) / 512 * 10
    var6 = cal.par_p11 * raw_pressure * raw_pressure / 65536
    var7 = var6 * raw_pressure / 128
    var8 = offset / 4 + var1 + var5 + var7
    var8 * 25 / 1_099_511_627_776 / 100
  end
end
