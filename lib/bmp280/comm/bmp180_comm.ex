defmodule BMP280.BMP180Comm do
  @moduledoc false

  alias BMP280.Transport

  @calib_register 0xAA
  @calib_size 22
  @ctrl_meas_register 0xF4

  @data_msb_register 0xF6
  @data_size 3

  @read_temp <<0x2E::8>>
  @read_pressure <<0x34::8>>

  @spec set_temperature_reading(Transport.t()) :: :ok | {:error, any()}
  def set_temperature_reading(transport) do
    Transport.write(
      transport,
      @ctrl_meas_register,
      @read_temp
    )
  end

  @spec set_pressure_reading(Transport.t()) :: :ok | {:error, any()}
  def set_pressure_reading(transport) do
    Transport.write(
      transport,
      @ctrl_meas_register,
      @read_pressure
    )
  end

  @spec read_calibration(Transport.t()) :: {:error, any} | {:ok, <<_::176>>}
  def read_calibration(transport) do
    Transport.read(transport, @calib_register, @calib_size)
  end

  @spec read_raw_samples(Transport.t()) :: {:error, any} | {:ok, <<_::24>>}
  def read_raw_samples(transport) do
    Transport.read(transport, @data_msb_register, @data_size)
  end
end
