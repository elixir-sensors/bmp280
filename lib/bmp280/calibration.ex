defmodule BMP280.Calibration do
  @moduledoc false

  @type t() :: __MODULE__.BMP280.t() | __MODULE__.BME280.t() | __MODULE__.BME680.t()

  @spec from_binary(BMP280.sensor_type(), binary | tuple) :: t()
  def from_binary(sensor_type, binary) do
    apply(calibration_module(%{type: sensor_type}), :from_binary, [binary])
  end

  @spec raw_to_temperature(t(), integer()) :: float()
  def raw_to_temperature(cal, raw_temp) do
    apply(calibration_module(cal), :raw_to_temperature, [cal, raw_temp])
  end

  @spec raw_to_pressure(t(), number(), integer()) :: float()
  def raw_to_pressure(cal, temp, raw_pressure) do
    apply(calibration_module(cal), :raw_to_pressure, [cal, temp, raw_pressure])
  end

  @spec raw_to_humidity(t(), number(), integer()) :: float() | :unknown
  def raw_to_humidity(cal, temp, raw_humidity) do
    if cal.type == :bmp280 do
      :unknown
    else
      apply(calibration_module(cal), :raw_to_humidity, [cal, temp, raw_humidity])
    end
  end

  defp calibration_module(%{type: :bmp280}), do: __MODULE__.BMP280
  defp calibration_module(%{type: :bme280}), do: __MODULE__.BME280
  defp calibration_module(%{type: :bme680}), do: __MODULE__.BME680
end
