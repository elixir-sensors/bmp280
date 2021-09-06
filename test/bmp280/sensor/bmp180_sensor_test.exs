defmodule BMP280.BME180SensorTest do
  use ExUnit.Case
  alias BMP280.BMP180Sensor
  doctest BMP280.BMP180Sensor

  @bme180_calibration1 %{
    type: :bmp180,
    ac1: 408,
    ac2: -72,
    ac3: -14383,
    ac4: 32741,
    ac5: 32757,
    ac6: 23153,
    b1: 6190,
    b2: 4,
    mb: -32768,
    mc: -8711,
    md: 2868
  }

  @bme180_calibration2 %{
    ac1: 6438,
    ac2: -1095,
    ac3: -14136,
    ac4: 34261,
    ac5: 25676,
    ac6: 16257,
    b1: 6515,
    b2: 40,
    mb: -32768,
    mc: -11786,
    md: 2408,
    type: :bmp180
  }

  test "bme180 1 calculations" do
    raw_temperature = <<108, 250, 0>>
    raw_pressure = <<93, 35, 0>>
    state = %{calibration: @bme180_calibration1, sea_level_pa: 100_000}

    measurement = BMP180Sensor.measurement_from_raw_samples(raw_temperature, raw_pressure, state)

    assert_in_delta 15.0, measurement.temperature_c, 0.05
    assert_in_delta 69964, measurement.pressure_pa, 5
  end

  test "bme180 2 calculations" do
    raw_temperature = <<95, 16, 0>>
    raw_pressure = <<161, 135, 0>>
    state = %{calibration: @bme180_calibration2, sea_level_pa: 100_000}

    measurement = BMP180Sensor.measurement_from_raw_samples(raw_temperature, raw_pressure, state)

    assert_in_delta 22.35, measurement.temperature_c, 0.05
    assert_in_delta 101_132.0, measurement.pressure_pa, 0.5
  end
end
