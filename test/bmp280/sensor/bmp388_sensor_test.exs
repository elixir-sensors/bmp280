defmodule BMP280.BMP388SensorTest do
  use ExUnit.Case
  alias BMP280.BMP388Sensor
  doctest BMP280.BMP388Sensor

  # TODO: use real value
  @bmp388_calibration %{
    type: :bmp388,
    par_t1: 999,
    par_t2: 555,
    par_t3: 88888,
    par_p1: 27,
    par_p2: -28872,
    par_p3: -42,
    par_p4: -48,
    par_p5: 9999,
    par_p6: 99999,
    par_p7: -1,
    par_p8: -7,
    par_p9: -244,
    par_p10: 48,
    par_p11: 32
  }

  test "calculate measurement from raw sample" do
    raw_samples = %{raw_temperature: 536_368, raw_pressure: 284_052}
    state = %{calibration: @bmp388_calibration, sea_level_pa: 100_000}

    measurement = BMP388Sensor.measurement_from_raw_samples(raw_samples, state)

    assert_in_delta 25.01374324340577, measurement.temperature_c, 0.0001
    assert_in_delta 114_036.86, measurement.pressure_pa, 0.01
    assert measurement.humidity_rh == :unknown
    assert measurement.dew_point_c == :unknown
    assert measurement.gas_resistance_ohms == :unknown
  end
end
