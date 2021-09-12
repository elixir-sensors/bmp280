# BMP280

[![Hex version](https://img.shields.io/hexpm/v/bmp280.svg "Hex version")](https://hex.pm/packages/bmp280)
[![CircleCI](https://circleci.com/gh/elixir-sensors/bmp280.svg?style=svg)](https://circleci.com/gh/elixir-sensors/bmp280)

Read temperature and pressure from Bosch
BMP180,
[BMP280](https://www.bosch-sensortec.com/products/environmental-sensors/pressure-sensors/bmp280/),
[BME280](https://www.bosch-sensortec.com/products/environmental-sensors/humidity-sensors-bme280/),
and
[BME680](https://www.bosch-sensortec.com/products/environmental-sensors/gas-sensors-bme680/)
sensors in Elixir.

## Usage

Here's an example use (most sensors are at address 0x77, but some are at 0x76):

```elixir
iex> {:ok, bmp} = BMP280.start_link(bus_name: "i2c-1", bus_address: 0x77)
{:ok, #PID<0.29929.0>}
iex> BMP280.measure(bmp)
{:ok,
 %BMP280.Measurement{
   altitude_m: 138.96206905098805,
   dew_point_c: 2.629181073094435,
   gas_resistance_ohms: 5279.474749704044,
   humidity_rh: 34.39681642351278,
   pressure_pa: 100818.86273677988,
   temperature_c: 18.645856498100876,
   timestamp_ms: 885906
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

## Nerves Livebook Firmware

[Nerves Livebook Firmware](https://github.com/fhunleth/nerves_livebook) contains BMP280 example, which shows you how to work with the BMP280 sensor on the [Nerves](https://www.nerves-project.org/) projects with example code that is runnable from the comfort of your browser.

## BMP3XX

Please check out this other Elixir library [BMP3XX](https://hex.pm/packages/bmp3xx) for Bosch [BMP388](https://www.bosch-sensortec.com/products/environmental-sensors/pressure-sensors/bmp388/) and [BMP390](https://www.bosch-sensortec.com/products/environmental-sensors/pressure-sensors/bmp390/) sensors.
