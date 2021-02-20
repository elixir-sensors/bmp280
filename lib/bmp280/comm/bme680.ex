defmodule BMP280.Comm.BME680 do
  @moduledoc false

  alias BMP280.{Calc, Transport}

  @type raw_pressure :: 0..0xFFFFF
  @type raw_temperature :: 0..0xFFFFF

  @ctrl_hum_register 0xF2
  @ctrl_meas_register 0xF4
  @press_msb_register 0x1F
  @gas_r_msb 0x2A
  @range_switching_error_register 0x04
  @calibration_block_1 0x8A
  @calibration_block_2 0xE1

  @spec send_enable(Transport.t()) :: :ok | {:error, any()}
  def send_enable(transport) do
    # normal
    mode = 3
    # x2 oversampling
    osrs_t = 2
    # x16 oversampling
    osrs_p = 5
    # x16 oversampling
    osrs_h = 5

    with :ok <- Transport.write(transport, @ctrl_hum_register, <<osrs_h>>) do
      Transport.write(
        transport,
        @ctrl_meas_register,
        <<osrs_t::size(3), osrs_p::size(3), mode::size(2)>>
      )
    end
  end

  @spec read_calibration(Transport.t()) :: {:error, any} | {:ok, binary}
  def read_calibration(transport) do
    with {:ok, <<rse>>} <- Transport.read(transport, @range_switching_error_register, 1),
         {:ok, first_part} <- Transport.read(transport, @calibration_block_1, 23),
         {:ok, second_part} <- Transport.read(transport, @calibration_block_2, 14) do
      {:ok, {rse, first_part, second_part}}
    end
  end

  @spec read_raw_samples(Transport.t()) :: {:error, any} | {:ok, Calc.raw()}
  def read_raw_samples(transport) do
    with {:ok, pth} <- Transport.read(transport, @press_msb_register, 8),
         {:ok, gas} <- Transport.read(transport, @gas_r_msb, 2) do
      <<pressure::20, _::4, temp::20, _::4, humidity::16>> = pth
      <<gas_r::10, _::2, gas_range_r::4>> = gas

      {:ok,
       %{
         raw_pressure: pressure,
         raw_temperature: temp,
         raw_humidity: humidity,
         gas_r: gas_r,
         gas_range_r: gas_range_r
       }}
    end
  end
end
