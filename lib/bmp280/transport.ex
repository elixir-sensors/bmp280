defmodule BMP280.Transport do
  @moduledoc false

  alias Circuits.I2C

  defstruct [:i2c, :address]
  @type t() :: %__MODULE__{i2c: I2C.bus(), address: I2C.address()}

  @spec open(String.t(), I2C.address()) :: {:ok, t()} | {:error, any()}
  def open(bus_name, address \\ 0x77) do
    with {:ok, i2c} <- I2C.open(bus_name) do
      {:ok, %__MODULE__{i2c: i2c, address: address}}
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
end
