defmodule BMP280.Comm do
  alias BMP280.Transport

  @moduledoc false

  @bmp2_reg_chip_id 0xD0
  @bmp3_reg_chip_id 0x00

  @spec sensor_type(Transport.t()) :: {:ok, BMP280.sensor_type()} | {:error, any()}
  def sensor_type(transport) do
    with bmp2_chip_id <- read_bmp2_chip_id(transport),
         bmp3_chip_id <- read_bmp3_chip_id(transport) do
      case result = bmp2_chip_id || bmp3_chip_id do
        nil -> {:error, :unknown_sensor_type}
        _ -> {:ok, result}
      end
    end
  end

  @spec read_bmp2_chip_id(Transport.t()) :: nil | BMP280.sensor_type() | {:error, any()}
  def read_bmp2_chip_id(transport) do
    case Transport.read(transport, @bmp2_reg_chip_id, 1) do
      {:error, reason} -> {:error, reason}
      {:ok, <<0x58>>} -> :bmp280
      {:ok, <<0x60>>} -> :bme280
      {:ok, <<0x61>>} -> :bme680
      _ -> nil
    end
  end

  @spec read_bmp3_chip_id(Transport.t()) :: nil | BMP280.sensor_type() | {:error, any()}
  def read_bmp3_chip_id(transport) do
    case Transport.read(transport, @bmp3_reg_chip_id, 1) do
      {:error, reason} -> {:error, reason}
      {:ok, <<0x50>>} -> :bmp388
      {:ok, <<0x60>>} -> :bmp390
      _ -> nil
    end
  end
end
