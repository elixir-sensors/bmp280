defmodule BMP280.CalcTest do
  use ExUnit.Case
  alias BMP280.Calc
  doctest BMP280.Calc

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

  test "dew point calculation doesn't crash" do
    assert Calc.dew_point(0, 30) == -40
  end
end
