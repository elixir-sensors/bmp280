defmodule BMP280.BME680Comm do
  @moduledoc false

  alias BMP280.Transport

  @coeff1_register 0x8A
  @coeff2_register 0xE1
  @coeff3_register 0x00
  @config_register 0x75
  @ctrl_gas1_register 0x71
  @ctrl_hum_register 0x72
  @ctrl_meas_register 0x74
  @gas_r_msb_register 0x2A
  @gas_wait0_register 0x64
  @meas_status0_register 0x1D
  @press_msb_register 0x1F
  @res_heat0_register 0x5A

  @oversampling_2x 2
  @oversampling_16x 5

  @sleep_mode 0
  @forced_mode 1

  @filter_size_3 2

  @spec set_sleep_mode(BMP280.Transport.t()) :: :ok | {:error, any}
  def set_sleep_mode(transport), do: set_power_mode(transport, @sleep_mode)

  @spec set_forced_mode(BMP280.Transport.t()) :: :ok | {:error, any}
  def set_forced_mode(transport), do: set_power_mode(transport, @forced_mode)

  defp set_power_mode(transport, mode) do
    with {:ok, <<no_change::6, _mode::2>>} <- Transport.read(transport, @ctrl_meas_register, 1) do
      Transport.write(transport, @ctrl_meas_register, <<no_change::6, mode::2>>)
    end
  end

  @doc """
  Set humidity oversampling, temperature oversampling and pressure oversampling to default values.
  """
  @spec set_oversampling(Transport.t()) :: :ok | {:error, any()}
  def set_oversampling(transport) do
    mode = @sleep_mode
    osrs_h = @oversampling_16x
    osrs_t = @oversampling_2x
    osrs_p = @oversampling_16x

    with :ok <- Transport.write(transport, @ctrl_hum_register, <<osrs_h>>) do
      Transport.write(transport, @ctrl_meas_register, <<osrs_t::3, osrs_p::3, mode::2>>)
    end
  end

  @doc """
  Set IIR filter size.
  """
  @spec set_filter(Transport.t()) :: :ok | {:error, any()}
  def set_filter(transport) do
    with {:ok, <<no_change1::3, _filter::3, no_change2::2>>} <-
           Transport.read(transport, @config_register, 1) do
      Transport.write(
        transport,
        @config_register,
        <<no_change1::3, @filter_size_3::3, no_change2::2>>
      )
    end
  end

  @spec enable_gas_sensor(Transport.t()) :: :ok | {:error, any()}
  def enable_gas_sensor(transport), do: set_gas_status(transport, 1)

  @spec disable_gas_sensor(Transport.t()) :: :ok | {:error, any()}
  def disable_gas_sensor(transport), do: set_gas_status(transport, 0)

  defp set_gas_status(transport, run_gas) do
    with {:ok, <<no_change1::3, _run_gas::1, no_change2::4>>} <-
           Transport.read(transport, @ctrl_gas1_register, 1) do
      Transport.write(
        transport,
        @ctrl_gas1_register,
        <<no_change1::3, run_gas::1, no_change2::4>>
      )
    end
  end

  @doc """
  Set gas sensor heater temperature in register code.
  """
  @spec set_gas_heater_temperature(Transport.t(), integer(), 0..9) :: :ok | {:error, any()}
  def set_gas_heater_temperature(transport, heater_resistance, heater_set_point \\ 0) do
    Transport.write(transport, @res_heat0_register + heater_set_point, <<heater_resistance>>)
  end

  @doc """
  Set gas sensor heater dutation in register code.
  """
  @spec set_gas_heater_duration(Transport.t(), integer(), 0..9) :: :ok | {:error, any()}
  def set_gas_heater_duration(transport, heater_duration, heater_set_point \\ 0) do
    Transport.write(transport, @gas_wait0_register + heater_set_point, <<heater_duration>>)
  end

  @doc """
  Set gas sensor conversion profile.
  """
  @spec set_gas_heater_profile(Transport.t(), 0..9) :: :ok | {:error, any()}
  def set_gas_heater_profile(transport, heater_set_point) do
    with {:ok, <<no_change::4, _heater_set_point::4>>} <-
           Transport.read(transport, @ctrl_gas1_register, 1) do
      Transport.write(transport, @ctrl_gas1_register, <<no_change::4, heater_set_point::4>>)
    end
  end

  @spec read_calibration(Transport.t()) ::
          {:ok, {<<_::184>>, <<_::112>>, <<_::40>>}} | {:error, any}
  def read_calibration(transport) do
    with {:ok, coeff1_binary} <- Transport.read(transport, @coeff1_register, 23),
         {:ok, coeff2_binary} <- Transport.read(transport, @coeff2_register, 14),
         {:ok, coeff3_binary} <- Transport.read(transport, @coeff3_register, 5),
         do: {:ok, {coeff1_binary, coeff2_binary, coeff3_binary}}
  end

  @spec read_raw_samples(Transport.t()) :: {:error, any} | {:ok, <<_::80>>}
  def read_raw_samples(transport) do
    with :ok <- set_forced_mode(transport),
         :ok <- ensure_new_data(transport),
         {:ok, pth_block} <- Transport.read(transport, @press_msb_register, 8),
         {:ok, gas_block} <- Transport.read(transport, @gas_r_msb_register, 2),
         do: {:ok, pth_block <> gas_block}
  end

  defp ensure_new_data(transport) do
    if new_data?(transport) do
      :ok
    else
      {:error, :data_not_ready}
    end
  end

  defp new_data?(transport) do
    with {:ok, <<new_data0::1, _gas_measuring::1, _measuring::1, _::1, _gas_meas_index0::4>>} <-
           Transport.read(transport, @meas_status0_register, 1) do
      new_data0 == 1
    end
  end
end
