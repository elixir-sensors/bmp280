defmodule BMP280.BME280SensorTest do
  use ExUnit.Case
  alias BMP280.BME280Sensor
  doctest BMP280.BME280Sensor

  @bme280_calibration1 %{
    type: :bme280,
    dig_H1: 75,
    dig_H2: 338,
    dig_H3: 0,
    dig_H4: 370,
    dig_H5: 60,
    dig_H6: 30,
    dig_P1: 36635,
    dig_P2: -10696,
    dig_P3: 3024,
    dig_P4: 11092,
    dig_P5: -241,
    dig_P6: -7,
    dig_P7: 12300,
    dig_P8: -12000,
    dig_P9: 5000,
    dig_T1: 28189,
    dig_T2: 26285,
    dig_T3: 50
  }

  @bme280_calibration2 %{
    type: :bme280,
    dig_H1: 75,
    dig_H2: 394,
    dig_H3: 0,
    dig_H4: 242,
    dig_H5: 56,
    dig_H6: 30,
    dig_P1: 37189,
    dig_P2: -10580,
    dig_P3: 3024,
    dig_P4: 8137,
    dig_P5: -87,
    dig_P6: -7,
    dig_P7: 9900,
    dig_P8: -10230,
    dig_P9: 4285,
    dig_T1: 28297,
    dig_T2: 26729,
    dig_T3: 50
  }

  test "bme280 1 calculations" do
    raw_samples = %{raw_temperature: 536_368, raw_pressure: 284_052, raw_humidity: 35181}
    state = %{calibration: @bme280_calibration1, sea_level_pa: 100_000}

    measurement = BME280Sensor.measurement_from_raw_samples(raw_samples, state)

    assert_in_delta 26.7460, measurement.temperature_c, 0.0001
    assert_in_delta 100_391.49, measurement.pressure_pa, 0.01
    assert_in_delta 59.2, measurement.humidity_rh, 0.1
    assert_in_delta 18.1, measurement.dew_point_c, 0.1
  end

  test "bme280 2 calculations" do
    raw_samples = %{raw_temperature: 516_344, raw_pressure: 316_593, raw_humidity: 26270}
    state = %{calibration: @bme280_calibration2, sea_level_pa: 100_000}

    measurement = BME280Sensor.measurement_from_raw_samples(raw_samples, state)

    assert_in_delta 20.2649, measurement.temperature_c, 0.0001
    assert_in_delta 100_278.40, measurement.pressure_pa, 0.01
    assert_in_delta 64.4, measurement.humidity_rh, 0.1
    assert_in_delta 13.3, measurement.dew_point_c, 0.1
  end
end
