defmodule BMP280.Comm do
  alias BMP280.{Calc, Transport}

  @moduledoc false

  @type raw_pressure :: 0..0xFFFFF
  @type raw_temperature :: 0..0xFFFFF

  @calib00_register 0x88

  @id_register 0xD0
  @calib26_register 0xE1
  @ctrl_hum_register 0xF2
  @ctrl_meas_register 0xF4
  @press_msb_register 0xF7

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

  @spec send_enable(Transport.t(), BMP280.sensor_type()) :: :ok | {:error, any()}
  def send_enable(transport, :bme280) do
    # x16 oversampling
    osrs_h = 5

    # Configure humidity sensing
    with :ok <- Transport.write(transport, @ctrl_hum_register, <<osrs_h>>) do
      # Finish by enabling the parts in common with the BMP280
      send_enable(transport, :bmp280)
    end
  end

  def send_enable(transport, _bmp280) do
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

  @spec read_calibration(Transport.t(), BMP280.sensor_type()) :: {:error, any} | {:ok, binary}
  def read_calibration(transport, :bme280) do
    with {:ok, first_part} <- Transport.read(transport, @calib00_register, 26),
         {:ok, second_part} <- Transport.read(transport, @calib26_register, 7) do
      {:ok, first_part <> second_part}
    end
  end

  def read_calibration(transport, _bmp280) do
    Transport.read(transport, @calib00_register, 24)
  end

  @spec read_raw_samples(Transport.t(), BMP280.sensor_type()) ::
          {:error, any} | {:ok, Calc.raw()}
  def read_raw_samples(transport, :bme280) do
    case Transport.read(transport, @press_msb_register, 8) do
      {:ok, <<pressure::20, _::4, temp::20, _::4, humidity::16>>} ->
        {:ok, %{raw_pressure: pressure, raw_temperature: temp, raw_humidity: humidity}}

      {:error, _reason} = error ->
        error
    end
  end

  def read_raw_samples(transport, _bmp280) do
    case Transport.read(transport, @press_msb_register, 6) do
      {:ok, <<pressure::20, _::4, temp::20, _::4>>} ->
        {:ok, %{raw_pressure: pressure, raw_temperature: temp}}

      {:error, _reason} = error ->
        error
    end
  end
end
