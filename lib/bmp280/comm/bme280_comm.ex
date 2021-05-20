defmodule BMP280.BME280Comm do
  @moduledoc false

  alias BMP280.Transport

  @calib00_register 0x88
  @calib26_register 0xE1
  @ctrl_hum_register 0xF2
  @ctrl_meas_register 0xF4
  @press_msb_register 0xF7

  @oversampling_2x 2
  @oversampling_16x 5

  @normal_mode 3

  @spec set_oversampling(Transport.t()) :: :ok | {:error, any()}
  def set_oversampling(transport) do
    mode = @normal_mode
    osrs_t = @oversampling_2x
    osrs_p = @oversampling_16x
    osrs_h = @oversampling_16x

    with :ok <- Transport.write(transport, @ctrl_hum_register, <<osrs_h>>) do
      Transport.write(
        transport,
        @ctrl_meas_register,
        <<osrs_t::size(3), osrs_p::size(3), mode::size(2)>>
      )
    end
  end

  @spec read_calibration(Transport.t()) :: {:error, any} | {:ok, <<_::264>>}
  def read_calibration(transport) do
    with {:ok, first_part} <- Transport.read(transport, @calib00_register, 26),
         {:ok, second_part} <- Transport.read(transport, @calib26_register, 7) do
      {:ok, first_part <> second_part}
    end
  end

  @spec read_raw_samples(Transport.t()) :: {:error, any} | {:ok, <<_::64>>}
  def read_raw_samples(transport) do
    Transport.read(transport, @press_msb_register, 8)
  end
end
