# Changelog

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
