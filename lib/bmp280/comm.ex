defmodule BMP280.Comm do
  alias BMP280.Transport

  @moduledoc false

  @id_register 0xD0
  @reset_register 0xE0

  @spec sensor_type(Transport.t()) :: {:ok, BMP280.sensor_type()} | {:error, any()}
  def sensor_type(transport) do
    case Transport.read(transport, @id_register, 1) do
      {:ok, <<id>>} -> {:ok, id_to_type(id)}
      error -> error
    end
  end

  defp id_to_type(0x55), do: :bmp180
  defp id_to_type(0x58), do: :bmp280
  defp id_to_type(0x60), do: :bme280
  defp id_to_type(0x61), do: :bme680
  defp id_to_type(unknown), do: unknown

  @doc """
  Reset the sensor
  """
  @spec reset(BMP280.Transport.t()) :: :ok | {:error, any}
  def reset(transport) do
    with :ok <- Transport.write(transport, @reset_register, <<0xB6>>),
         do: Process.sleep(10)
  end
end
