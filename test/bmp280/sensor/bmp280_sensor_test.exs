defmodule BMP280.BMP280SensorTest do
  use ExUnit.Case
  alias BMP280.BMP280Sensor
  doctest BMP280.BMP280Sensor

  @bmp280_calibration %{
    type: :bmp280,
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

  test "bmp280 calculations" do
    raw_samples = <<69, 89, 64, 130, 243, 0>>
    state = %{calibration: @bmp280_calibration, sea_level_pa: 100_000}

    measurement = BMP280Sensor.measurement_from_raw_samples(raw_samples, state)

    assert_in_delta 26.7460, measurement.temperature_c, 0.0001
    assert_in_delta 100_391.49, measurement.pressure_pa, 0.01
    assert measurement.humidity_rh == :unknown
    assert measurement.dew_point_c == :unknown
    assert measurement.gas_resistance_ohms == :unknown
  end
end
