defmodule BMP280.BMP180Comm do
  @moduledoc false

  alias BMP280.Transport

  @calib00_register 0xAA
  @ctrl_meas_register 0xF4
  @data_msb_register 0xF6

  @read_temp 0x2E
  @read_pressure 0x34

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
    Transport.read(transport, @calib00_register, 22)
  end

  @spec read_raw_samples(Transport.t()) :: {:error, any} | {:ok, <<_::16>>}
  def read_raw_samples(transport) do
   Transport.read(transport, @data_msb_register, 3)
  end
end
