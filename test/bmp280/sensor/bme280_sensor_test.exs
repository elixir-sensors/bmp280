defmodule BMP280.BME280SensorTest do
  use ExUnit.Case
  alias BMP280.BME280Sensor
  doctest BMP280.BME280Sensor

  @bme280_calibration1 %{
    type: :bme280,
    dig_h1: 75,
    dig_h2: 338,
    dig_h3: 0,
    dig_h4: 370,
    dig_h5: 60,
    dig_h6: 30,
    dig_p1: 36_635,
    dig_p2: -10_696,
    dig_p3: 3024,
    dig_p4: 11_092,
    dig_p5: -241,
    dig_p6: -7,
    dig_p7: 12_300,
    dig_p8: -12_000,
    dig_p9: 5000,
    dig_t1: 28_189,
    dig_t2: 26_285,
    dig_t3: 50
  }

  @bme280_calibration2 %{
    type: :bme280,
    dig_h1: 75,
    dig_h2: 394,
    dig_h3: 0,
    dig_h4: 242,
    dig_h5: 56,
    dig_h6: 30,
    dig_p1: 37_189,
    dig_p2: -10_580,
    dig_p3: 3024,
    dig_p4: 8137,
    dig_p5: -87,
    dig_p6: -7,
    dig_p7: 9900,
    dig_p8: -10_230,
    dig_p9: 4285,
    dig_t1: 28_297,
    dig_t2: 26_729,
    dig_t3: 50
  }

  test "bme280 1 calculations" do
    raw_samples = <<69, 89, 64, 130, 243, 0, 137, 109>>
    state = %{calibration: @bme280_calibration1, sea_level_pa: 100_000}

    measurement = BME280Sensor.measurement_from_raw_samples(raw_samples, state)

    assert_in_delta 26.7460, measurement.temperature_c, 0.0001
    assert_in_delta 100_391.49, measurement.pressure_pa, 0.01
    assert_in_delta 59.2, measurement.humidity_rh, 0.1
    assert_in_delta 18.1, measurement.dew_point_c, 0.1
  end

  test "bme280 2 calculations" do
    raw_samples = <<77, 75, 16, 126, 15, 128, 102, 158>>
    state = %{calibration: @bme280_calibration2, sea_level_pa: 100_000}

    measurement = BME280Sensor.measurement_from_raw_samples(raw_samples, state)

    assert_in_delta 20.2649, measurement.temperature_c, 0.0001
    assert_in_delta 100_278.40, measurement.pressure_pa, 0.01
    assert_in_delta 64.4, measurement.humidity_rh, 0.1
    assert_in_delta 13.3, measurement.dew_point_c, 0.1
  end
end
