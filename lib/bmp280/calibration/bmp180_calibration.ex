defmodule BMP280.BMP180Calibration do
  @moduledoc false

  @type t() :: %{
          type: :bmp180,
          ac1: integer,
          ac2: integer,
          ac3: integer,
          ac4: integer,
          ac5: integer,
          ac6: integer,
          b1: integer,
          b2: integer,
          mb: integer,
          mc: integer,
          md: integer
        }

  @two_2 :math.pow(2, 2)
  @two_4 :math.pow(2, 4)
  @two_8 :math.pow(2, 8)
  @two_11 :math.pow(2, 11)
  @two_12 :math.pow(2, 12)
  @two_13 :math.pow(2, 13)
  @two_15 :math.pow(2, 15)
  @two_16 :math.pow(2, 16)

  @spec from_binary(binary) :: t()
  def from_binary(
        <<ac1::little-16, ac2::little-16, ac3::little-16, ac4::little-unsigned-16,
          ac5::little-unsigned-16, ac6::little-unsigned-16, b1::little-16, b2::little-16,
          mb::little-16, mc::little-16, md::little-16>>
      ) do
    %{
      type: :bmp180,
      ac1: s(ac1),
      ac2: s(ac2),
      ac3: s(ac3),
      ac4: s(ac4),
      ac5: s(ac5),
      ac6: s(ac6),
      b1: s(b1),
      b2: s(b2),
      mb: s(mb),
      mc: s(mc),
      md: s(md)
    }
  end

  @spec raw_to_temperature(t(), integer()) :: float()
  def raw_to_temperature(cal, raw_temp) do
    x1 = (raw_temp - cal.ac6) * cal.ac5 / @two_15
    x2 = cal.mc * @two_11 / (x1 + cal.md)
    b5 = x1 + x2
    (b5 + 8) / @two_4 / 10
  end

  @spec raw_to_pressure(t(), number(), number()) :: float()
  def raw_to_pressure(cal, temp, raw_pressure) do
    b5 = temp * 10 * @two_4 - 8
    b6 = b5 - 4000
    x1 = cal.b2 * (b6 * b6) / @two_12 / @two_11
    x2 = cal.ac2 * b6 / @two_11
    x3 = x1 + x2
    b3 = (cal.ac1 * 4 + x3 + 2) / 4
    x1 = cal.ac3 * b6 / @two_13
    x2 = cal.b1 * (b6 * b6 / @two_12) / @two_16
    x3 = (x1 + x2 + 2) / @two_2
    b4 = cal.ac4 * (x3 + 32768) / @two_15
    b7 = (raw_pressure - b3) * 50000
    p = p(b7, b4)
    x1 = p / @two_8 * (p / @two_8)
    x1 = x1 * 3038 / @two_16
    x2 = -7357 * p / @two_16
    p + (x1 + x2 + 3791) / @two_4
  end

  defp p(b7, b4) when b7 < 0x80000000, do: b7 * 2 / b4
  defp p(b7, b4), do: b7 / b4 * 2

  defp s(data), do: data
end
