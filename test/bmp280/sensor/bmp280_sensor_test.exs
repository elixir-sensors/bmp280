defmodule BMP280.BMP280SensorTest do
  use ExUnit.Case
  alias BMP280.BMP280Sensor
  doctest BMP280.BMP280Sensor

  @bmp280_calibration %{
    type: :bmp280,
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
