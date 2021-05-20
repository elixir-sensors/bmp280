defmodule BMP280.BMP280Comm do
  @moduledoc false

  alias BMP280.Transport

  @calib00_register 0x88
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

    Transport.write(
      transport,
      @ctrl_meas_register,
      <<osrs_t::size(3), osrs_p::size(3), mode::size(2)>>
    )
  end

  @spec read_calibration(Transport.t()) :: {:error, any} | {:ok, <<_::192>>}
  def read_calibration(transport) do
    Transport.read(transport, @calib00_register, 24)
  end

  @spec read_raw_samples(Transport.t()) :: {:error, any} | {:ok, <<_::48>>}
  def read_raw_samples(transport) do
    Transport.read(transport, @press_msb_register, 6)
  end
end
