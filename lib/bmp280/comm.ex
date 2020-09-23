defmodule BMP280.Comm do
  alias BMP280.Transport

  @moduledoc false

  @type raw_pressure :: 0..0xFFFFF
  @type raw_temperature :: 0..0xFFFFF

  @id_register 0xD0
  @ctrl_meas_register 0xF4

  @spec sensor_type(Transport.t()) :: {:ok, BMP280.sensor_type()} | {:error, any()}
  def sensor_type(transport) do
    case Transport.read(transport, @id_register, 1) do
      {:ok, <<id>>} -> {:ok, id_to_type(id)}
      error -> error
    end
  end

  defp id_to_type(0x58), do: :bmp280
  defp id_to_type(0x60), do: :bme280
  defp id_to_type(unknown), do: unknown

  @spec send_enable(Transport.t()) :: :ok | {:error, any()}
  def send_enable(transport) do
    # normal
    mode = 3
    # x2 oversampling
    osrs_t = 2
    # x16 oversampling
    osrs_p = 5

    Transport.write(
      transport,
      @ctrl_meas_register,
      <<osrs_t::size(3), osrs_p::size(3), mode::size(2)>>
    )
  end

  @spec read_calibration(Transport.t()) :: {:error, any} | {:ok, binary}
  def read_calibration(transport) do
    Transport.read(transport, 0x88, 24)
  end

  @spec read_raw_samples(Transport.t()) ::
          {:error, any} | {:ok, raw_pressure(), raw_temperature()}
  def read_raw_samples(transport) do
    case Transport.read(transport, 0xF7, 6) do
      {:ok, <<pressure::size(20), _::size(4), temp::size(20), _::size(4)>>} ->
        {:ok, pressure, temp}

      {:error, _reason} = error ->
        error
    end
  end
end
