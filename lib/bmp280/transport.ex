defmodule BMP280.Transport do
  @moduledoc false

  require Logger

  alias Circuits.I2C

  defstruct [:i2c, :address]
  @type t() :: %__MODULE__{i2c: I2C.bus(), address: I2C.address()}

  @spec open(String.t(), I2C.address()) :: {:ok, t()} | {:error, any()}
  def open(bus_name, address) do
    if address_exist?(address) do
      case I2C.open(bus_name) do
        {:ok, i2c} ->
          Logger.info("Opened connection to address #{address} on bus #{bus_name}")
          {:ok, %__MODULE__{i2c: i2c, address: address}}

        error ->
          Logger.error("Could not connect to address #{address} on bus #{bus_name}")
          error
      end
    else
      Logger.error("Address #{address} not found")
      {:error, :invalid_address}
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
