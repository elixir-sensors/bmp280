defmodule BMP280.Measurement do
  @moduledoc """
  One measurement from the sensor

  This module holds one measurement from the sensor in SI units. Helper functions
  are available non-SI units.
  """
  defstruct [:temperature_c, :pressure_pa, :altitude_m, :humidity_rh]

  @type t :: %__MODULE__{
          temperature_c: number(),
          pressure_pa: number(),
          altitude_m: number(),
          humidity_rh: number()
        }

  @doc """
  Return the temperature in the specified units
  """
  @spec temperature(t(), :celsius | :fahrenheit) :: number()
  def temperature(measurement, units \\ :celsius)
  def temperature(measurement, :celsius), do: measurement.temperature_c
  def temperature(measurement, :fahrenheit), do: 32 + 1.8 * measurement.temperature_c

  @doc """
  Return the pressure in the specified units
  """
  @spec pressure(t(), :pascal | :in_hg) :: number()
  def pressure(measurement, units \\ :pascal)
  def pressure(measurement, :pascal), do: measurement.pressure_pa
  def pressure(measurement, :in_hg), do: measurement.pressure_pa * 0.00029529983071445

  @doc """
  Return the estimated altitude
  """
  @spec altitude(t(), :meters | :feet) :: number()
  def altitude(measurement, units \\ :meters)
  def altitude(measurement, :meters), do: measurement.altitude_m
  def altitude(measurement, :feet), do: 3.2808399 * measurement.altitude_m
end
