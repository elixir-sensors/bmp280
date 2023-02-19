# Changelog

## v0.2.12

* Improvements
  * Update online documentation using ex_doc 0.29
  * Bump elixir versions in ci

## v0.2.11

* Improvements
  * Support both circuits_i2c 1.0 and 0.3.x

## v0.2.10

* Fixes
  * Fix dew point calculation from raising when sensor can't measure the
    relative humidity

## v0.2.9

* New features
  * Add BMP180 support

## v0.2.8

* Improvements
  * Mention BMP3XX in readme
  * Log helpful message on init
  * Add credo as a code quality tool
  * Refactor comm modules in a way they can focus on communicating with the device

* Fixes
  * Fix typespec links in the hexdoc

## v0.2.7

* Improvements
  * Update Circle config for OTP 24
  * Remove the "Support for other Bosch barometric sensors" section from README

* Fixes
  * Halt the sensor initialization when device is not found

## v0.2.6

* Improvements
  * Make README.md the main doc page
  * Add "Nerves Livebook Firmware" section to README.md

* Fixes
  * Fix broken CI link

## v0.2.5

* New features
  * Stable basic gas support

* API changes
  * none

* Improvements
  * Restructure internal code organization.
  * Change ambient temperature estimate from `30 C` to `25 C` for setting up gas measurements

* Fixes
  * Sleep 10 ms after soft reset so that the sensor data can be read properly.
  * Correct the parser for gas-related calibration data. Previously, some data types were wrong.
  * Fix a broken link to BMP280 sensor in README.

## v0.2.4

This release adds support for reading the BME680's gas resistance sensor. In the
future, this will be converted to an indoor air quality measurement.

* API changes
  * Sensor measurements are now obtained by calling `BMP280.measure/1` for
    consistency with other Elixir sensor libraries. `BMP280.read/1` is
    deprecated.

* Improvements
  * The library now polls the sensor once a second. Calls to `BMP280.measure/1`
    return the latest reading rather than making an I2C transaction.
  * Measurements now include a timestamp (`System.monotonic_time(:millisecond)`)
  * Various internal code improvements to make it easier to support many Bosch
    sensors

## v0.2.3

* New features
  * Support temperature, humidity and pressure measurements on the BME680. VOC
    measurements are not supported yet.

## v0.2.2

Note: This release removes the non-SI conversion helper functions. They were
inconsistently defined, and it seems better for some other library to care more
about conversions.

* New features
  * Add dew point approximation

## v0.2.1

* Bug fixes
  * Fix `BMP280.detect/2` so that it only probes one I2C bus address.

## v0.2.0

* New features
  * Add support for the BME280 and for reading relative humidity measurements
    from it

## v0.1.1

* Fixes
  * Fixed `:bus_address` parameter. It was incorrectly referred to as `:address`
    when used.

## v0.1.0

Initial release
