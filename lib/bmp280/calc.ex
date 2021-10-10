defmodule BMP280.Calc do
  @moduledoc false

  @doc """
  Calculate the altitude using the current pressure and sea level pressure
  """
  @spec pressure_to_altitude(number(), number()) :: float()
  def pressure_to_altitude(p, sea_level_pa) do
    44_330 * (1 - :math.pow(p / sea_level_pa, 1 / 5.255))
  end

  @doc """
  Calculate the sea level pressure based on the specified altitude
  """
  @spec sea_level_pressure(number(), number()) :: float()
  def sea_level_pressure(p, altitude) do
    p / :math.pow(1 - altitude / 44_330, 5.255)
  end

  @doc """
  Calculate the dew point

  This uses the August–Roche–Magnus approximation. See
  https://en.wikipedia.org/wiki/Clausius%E2%80%93Clapeyron_relation#Meteorology_and_climatology
  """
  @spec dew_point(number(), number()) :: float()
  def dew_point(humidity_rh, temperature_c) when is_number(humidity_rh) and humidity_rh > 0 do
    log_rh = :math.log(humidity_rh / 100)
    t = temperature_c

    243.04 * (log_rh + 17.625 * t / (243.04 + t)) / (17.625 - log_rh - 17.625 * t / (243.04 + t))
  end

  def dew_point(_humidity_rh, _temperature_c) do
    # Handle out-of-range inputs. This only happens under extreme conditions.
    # As for what to return, there's nothing obviously great. According to the
    # Internets, the lowest recorded humidity was in Iran and had a dew point
    # of -33.2. I've observed dew points in the -30s being returned from above.
    # The logic for returning -40 is that it's both lower than what was
    # observed and somewhat special since it's the Celsius/Fahrenheit crossover
    # point.
    -40
  end
end
