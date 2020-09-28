# BMP280

[![Hex version](https://img.shields.io/hexpm/v/bmp280.svg "Hex version")](https://hex.pm/packages/bmp280)
[![CircleCI](https://circleci.com/gh/fhunleth/bmp280.svg?style=svg)](https://circleci.com/gh/fhunleth/bmp280)

Read temperature and pressure from Bosch
[BMP280](https://www.bosch-sensortec.com/products/environmental-sensors/pressure-sensors/pressure-sensors-bmp280-1.html)
and
[BME280](https://www.bosch-sensortec.com/products/environmental-sensors/humidity-sensors-bme280/)
sensors in Elixir.

Add `{:bmp280, "~> 0.2.0"}` to your project's dependencies. Here's an example
use:

```elixir
iex> {:ok, bmp} = BMP280.start_link(bus_name: "i2c-1", bus_address: 0x77)
{:ok, \#PID<0.29929.0>}
iex> BMP280.read(bmp)
{:ok,
 %BMP280.Measurement{
   altitude_m: 13.842046523689644,
   dew_point_c: 18.438691684856007,
   humidity_rh: 51.59938493850065,
   pressure_pa: 99836.02154563366,
   temperature_c: 29.444089211523533
 }}
```

Depending on your hardware configuration, you may need to modify the call to
`BMP280.start_link/1`. See `t:BMP280.options/0` for parameters.

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

Successors to the BMP280 and BME280 look similar, but not tested yet. If you're
using one of them, please help me by either verifying that they work or adding
support for them.

