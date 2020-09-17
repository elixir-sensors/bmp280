defmodule BMP280.Calibration do
  @moduledoc false

  defstruct [
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
    :dig_P9
  ]

  @type uint16() :: 0..65535
  @type int16() :: -32768..32767

  @type t() :: %__MODULE__{
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
          dig_P9: int16()
        }

  @spec from_binary(<<_::192>>) :: BMP280.Calibration.t()
  def from_binary(
        <<dig_T1::little-unsigned-size(16), dig_T2::little-signed-size(16),
          dig_T3::little-signed-size(16), dig_P1::little-unsigned-size(16),
          dig_P2::little-signed-size(16), dig_P3::little-signed-size(16),
          dig_P4::little-signed-size(16), dig_P5::little-signed-size(16),
          dig_P6::little-signed-size(16), dig_P7::little-signed-size(16),
          dig_P8::little-signed-size(16), dig_P9::little-signed-size(16)>>
      ) do
    %__MODULE__{
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
end
