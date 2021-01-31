defmodule BMP280.Measurement do
  @moduledoc """
  One sensor measurement report

  The temperature, pressure and relative humidity measurements are computed
  directly from the sensor. All other values are derived.
  """
  defstruct [
    :temperature_c,
    :pressure_pa,
    :altitude_m,
    humidity_rh: :unknown,
    dew_point_c: :unknown,
    gas_resistance_ohms: :unknown,
    timestamp_ms: :unknown
  ]

  @type t :: %__MODULE__{
          temperature_c: number(),
          pressure_pa: number(),
          altitude_m: number(),
          humidity_rh: number() | :unknown,
          dew_point_c: number() | :unknown,
          gas_resistance_ohms: number() | :unknown,
          timestamp_ms: number() | :unknown
        }
end
