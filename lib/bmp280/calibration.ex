defmodule BMP280.Calibration do
  @moduledoc false

  defstruct [
    :has_humidity?,
    :dig_T1,
    :dig_T2,
    :dig_T3,
    :dig_P1,
    :dig_P2,
    :dig_P3,
    :dig_P4,
    :dig_P5,
    :dig_P6,
    :dig_P7,
    :dig_P8,
    :dig_P9,
    :dig_H1,
    :dig_H2,
    :dig_H3,
    :dig_H4,
    :dig_H5,
    :dig_H6
  ]

  @type uint16() :: 0..65535
  @type int16() :: -32768..32767
  @type uint8() :: 0..255
  @type int8() :: -128..127
  @type int12() :: -2048..2047

  @type t() :: %__MODULE__{
          has_humidity?: boolean(),
          dig_T1: uint16(),
          dig_T2: int16(),
          dig_T3: int16(),
          dig_P1: uint16(),
          dig_P2: int16(),
          dig_P3: int16(),
          dig_P4: int16(),
          dig_P5: int16(),
          dig_P6: int16(),
          dig_P7: int16(),
          dig_P8: int16(),
          dig_P9: int16(),
          dig_H1: uint8(),
          dig_H2: int16(),
          dig_H3: uint8(),
          dig_H4: int12(),
          dig_H5: int12(),
          dig_H6: int8()
        }

  @spec from_binary(<<_::192>> | <<_::248>>) :: BMP280.Calibration.t()
  def from_binary(
        <<dig_T1::little-16, dig_T2::little-signed-16, dig_T3::little-signed-16,
          dig_P1::little-16, dig_P2::little-signed-16, dig_P3::little-signed-16,
          dig_P4::little-signed-16, dig_P5::little-signed-16, dig_P6::little-signed-16,
          dig_P7::little-signed-16, dig_P8::little-signed-16, dig_P9::little-signed-16>>
      ) do
    %__MODULE__{
      has_humidity?: false,
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
        <<dig_T1::little-16, dig_T2::little-signed-16, dig_T3::little-signed-16,
          dig_P1::little-16, dig_P2::little-signed-16, dig_P3::little-signed-16,
          dig_P4::little-signed-16, dig_P5::little-signed-16, dig_P6::little-signed-16,
          dig_P7::little-signed-16, dig_P8::little-signed-16, dig_P9::little-signed-16, _, dig_H1,
          dig_H2::little-signed-16, dig_H3, dig_H4h, dig_H4l::4, dig_H5l::4, dig_H5h,
          dig_H6::signed>>
      ) do
    %__MODULE__{
      has_humidity?: true,
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

  @spec raw_to_humidity(t(), number(), integer()) :: float() | :unknown
  def raw_to_humidity(%{has_humidity?: true} = cal, temp, raw_humidity)
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

  def raw_to_humidity(_cal, _temp, _raw), do: :unknown
end
