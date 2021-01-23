defmodule BMP280.CalcTest do
  use ExUnit.Case
  alias BMP280.Calc
  doctest BMP280.Calc

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

  @bme280_calibration %{
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

  @bme680_calibration %{
    type: :bme680,
    par_gh1: -30,
    par_gh2: -5969,
    par_gh3: 18,
    par_h1: 717,
    par_h2: 1021,
    par_h3: 0,
    par_h4: 45,
    par_h5: 20,
    par_h6: 120,
    par_h7: -100,
    par_p1: 35395,
    par_p10: 30,
    par_p2: -10405,
    par_p3: 88,
    par_p4: 4836,
    par_p5: -118,
    par_p6: 30,
    par_p7: 26,
    par_p8: -765,
    par_p9: -3367,
    par_t1: 26195,
    par_t2: 26290,
    par_t3: 3,
    range_switching_error: 243
  }

  test "bmp280 calculations" do
    raw = %{raw_temperature: 536_368, raw_pressure: 284_052}
    measurement = Calc.raw_to_measurement(@bmp280_calibration, 100_000, raw)

    assert_in_delta 26.7460, measurement.temperature_c, 0.0001
    assert_in_delta 100_391.49, measurement.pressure_pa, 0.01
    assert measurement.humidity_rh == :unknown
    assert measurement.dew_point_c == :unknown
  end

  test "bme280 1 calculations" do
    raw = %{raw_temperature: 536_368, raw_pressure: 284_052, raw_humidity: 35181}
    measurement = Calc.raw_to_measurement(@bme280_calibration, 100_000, raw)

    assert_in_delta 26.7460, measurement.temperature_c, 0.0001
    assert_in_delta 100_391.49, measurement.pressure_pa, 0.01
    assert_in_delta 59.2, measurement.humidity_rh, 0.1
    assert_in_delta 18.1, measurement.dew_point_c, 0.1
  end

  test "bme280 2 calculations" do
    raw = %{raw_temperature: 516_344, raw_pressure: 316_593, raw_humidity: 26270}
    measurement = Calc.raw_to_measurement(@bme280_calibration2, 100_000, raw)

    assert_in_delta 20.2649, measurement.temperature_c, 0.0001
    assert_in_delta 100_278.40, measurement.pressure_pa, 0.01
    assert_in_delta 64.4, measurement.humidity_rh, 0.1
    assert_in_delta 13.3, measurement.dew_point_c, 0.1
  end

  test "bme680 calculations" do
    raw = %{raw_temperature: 480_732, raw_pressure: 393_705, raw_humidity: 16820}
    measurement = Calc.raw_to_measurement(@bme680_calibration, 100_000, raw)

    assert_in_delta 19.3113, measurement.temperature_c, 0.0001
    assert_in_delta 100_977.52, measurement.pressure_pa, 0.01
    assert_in_delta 25.2, measurement.humidity_rh, 0.1
    assert_in_delta -1.1, measurement.dew_point_c, 0.1
  end

  test "altitude calculation" do
    sea_level_pa = 101_325
    current_pa = 100_736.516
    altitude = 49.109577

    assert_in_delta altitude, Calc.pressure_to_altitude(current_pa, sea_level_pa), 0.001
    assert_in_delta sea_level_pa, Calc.sea_level_pressure(current_pa, altitude), 0.001
  end

  test "dew point calculation" do
    assert_in_delta 14.87, Calc.dew_point(64, 22), 0.01
  end
end
