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
        <<ac1::16, ac2::16, ac3::16, ac4::16, ac5::16, ac6::16, b1::16, b2::16, mb::16, mc::16,
          md::16>>
      ) do
    %{
      type: :bmp180,
      ac1: swap(ac1),
      ac2: swap(ac2),
      ac3: swap(ac3),
      ac4: swap_unsigned(ac4),
      ac5: swap_unsigned(ac5),
      ac6: swap_unsigned(ac6),
      b1: swap(b1),
      b2: swap(b2),
      mb: swap(mb),
      mc: swap(mc),
      md: swap(md)
    }
  end

  @spec raw_to_temperature(t(), <<_::24>>) :: float()
  def raw_to_temperature(cal, <<raw_temp::16, _::8>>) do
    x1 = (raw_temp - cal.ac6) * cal.ac5 / @two_15
    x2 = cal.mc * @two_11 / (x1 + cal.md)
    b5 = x1 + x2
    (b5 + 8) / @two_4 / 10
  end

  @spec raw_to_pressure(t(), number(), <<_::24>>) :: float()
  def raw_to_pressure(cal, temp, <<raw_pressure::16, _::8>>) do
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

  defp swap(data) do
    <<a::8, b::8>> = <<data::16>>
    <<data::little-signed-16>> = <<b::8, a::8>>
    data
  end

  defp swap_unsigned(data) do
    <<a::8, b::8>> = <<data::16>>
    <<data::little-unsigned-16>> = <<b::8, a::8>>
    data
  end
end
