defmodule BMP280 do
  # This delegate everything to BMP2XX for backward compatibility.

  defdelegate start_link(init_arg), to: BMP2XX
  defdelegate sensor_type(server), to: BMP2XX
  defdelegate measure(server), to: BMP2XX
  defdelegate update_sea_level_pressure(server, new_estimate), to: BMP2XX
  defdelegate force_altitude(server, altitude_m), to: BMP2XX
  defdelegate detect(bus_name, bus_address), to: BMP2XX
end
