# BMP280

[![Hex version](https://img.shields.io/hexpm/v/bmp280.svg "Hex version")](https://hex.pm/packages/bmp280)
[![CircleCI](https://circleci.com/gh/fhunleth/bmp280.svg?style=svg)](https://circleci.com/gh/fhunleth/bmp280)

Read temperature and pressure measurements from a [Bosch
BMP280](https://www.bosch-sensortec.com/products/environmental-sensors/pressure-sensors/pressure-sensors-bmp280-1.html)
sensor in Elixir.

Add `{:bmp280, "~> 0.1.0"}` to your project's dependencies. Here's an example
use:

```elixir
iex> {:ok, bmp} = BMP280.start_link([])
{:ok, \#PID<0.29929.0>}
iex> BMP280.read(bmp)
{:ok,
 %BMP280.Measurement{
   altitude_m: 46.60861034844783,
   pressure_pa: 100766.41878837062,
   temperature_c: 17.373406414553756
 }}
```

All measurements are reported in SI units.

The altitude measurement is computed from the measured barometric pressure. To
be accurate, it requires either the current sea level pressure or the current
altitude. Here's an example:

```elixir
iex> BMP280.force_altitude(bmp, 100)
:ok
```

Subsequent altitude reports should be more accurate until the weather changes.

## Support for other Bosch barometric sensors

Successors to the BMP280 are similar, but not supported yet. If you're using one
of them, please help me add support for them.
