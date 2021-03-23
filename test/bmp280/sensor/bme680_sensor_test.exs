defmodule BMP280.BME680SensorTest do
  use ExUnit.Case
  alias BMP280.BME680Sensor
  doctest BMP280.BME680Sensor

  @bme680_calibration %{
    type: :bme680,
    par_t1: 26195,
    par_t2: 26290,
    par_t3: 3,
    par_p1: 35395,
    par_p2: -10405,
    par_p3: 88,
    par_p4: 4836,
    par_p5: -118,
    par_p6: 30,
    par_p7: 26,
    par_p8: -765,
    par_p9: -3367,
    par_p10: 30,
    par_h1: 717,
    par_h2: 1021,
    par_h3: 0,
    par_h4: 45,
    par_h5: 20,
    par_h6: 120,
    par_h7: -100,
    par_gh1: -30,
    par_gh2: -5969,
    par_gh3: 18,
    range_switching_error: 0,
    res_heat_range: 0,
    res_heat_val: 0
  }

  test "bme680 calculations" do
    raw_samples = %{
      raw_temperature: 480_732,
      raw_pressure: 393_705,
      raw_humidity: 16820,
      raw_gas_resistance: 195,
      raw_gas_range: 9
    }

    state = %{calibration: @bme680_calibration, sea_level_pa: 100_000}

    measurement = BME680Sensor.measurement_from_raw_samples(raw_samples, state)

    assert_in_delta 19.3113, measurement.temperature_c, 0.0001
    assert_in_delta 100_977.52, measurement.pressure_pa, 0.01
    assert_in_delta 25.2, measurement.humidity_rh, 0.1
    assert_in_delta -1.1, measurement.dew_point_c, 0.1
    assert_in_delta 20467.2644, measurement.gas_resistance_ohms, 0.0001
  end
end
