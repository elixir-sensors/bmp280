defmodule BMP280.Comm.BMP280 do
  @moduledoc false

  alias BMP280.{Calc, Transport}

  @type raw_pressure :: 0..0xFFFFF
  @type raw_temperature :: 0..0xFFFFF

  @calib00_register 0x88
  @ctrl_meas_register 0xF4
  @press_msb_register 0xF7

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
    Transport.read(transport, @calib00_register, 24)
  end

  @spec read_raw_samples(Transport.t()) :: {:error, any} | {:ok, Calc.raw()}
  def read_raw_samples(transport) do
    case Transport.read(transport, @press_msb_register, 6) do
      {:ok, <<pressure::20, _::4, temp::20, _::4>>} ->
        {:ok, %{raw_pressure: pressure, raw_temperature: temp}}

      {:error, _reason} = error ->
        error
    end
  end
end
