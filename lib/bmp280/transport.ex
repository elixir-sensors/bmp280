defmodule BMP280.Transport do
  @moduledoc false

  require Logger

  alias Circuits.I2C

  defstruct [:i2c, :address]
  @type t() :: %__MODULE__{i2c: I2C.bus(), address: I2C.address()}

  @spec open(String.t(), I2C.address()) :: {:ok, t()} | {:error, any()}
  def open(bus_name, address) do
    address_hex = Integer.to_string(address, 16)

    case I2C.open(bus_name) do
      {:ok, i2c} ->
        if address_exist?(address) do
          Logger.info("Opened bus #{bus_name}. Address 0x#{address_hex} found.")
          {:ok, %__MODULE__{i2c: i2c, address: address}}
        else
          Logger.error("Address 0x#{address_hex} not found")
          {:error, :address_not_found}
        end

      {:error, reason} ->
        Logger.error("Could not open bus #{bus_name} (reason: #{reason})")
        {:error, reason}
    end
  end

  @spec write(t(), 0..255, iodata()) :: :ok | {:error, any()}
  def write(transport, register, data) do
    I2C.write(transport.i2c, transport.address, [register, data])
  end

  @spec read(t(), 0..255, non_neg_integer()) :: {:ok, binary()} | {:error, any()}
  def read(transport, register, bytes_to_read) do
    I2C.write_read(transport.i2c, transport.address, <<register>>, bytes_to_read)
  end

  defp address_exist?(address) do
    case I2C.discover_one([address]) do
      {:ok, _} -> true
      _ -> false
    end
  end
end
