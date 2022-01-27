defmodule BMP280.SensorTest do
  use ExUnit.Case
  alias BMP280.Sensor
  doctest BMP280.Sensor

  @valid_opts [sensor_type: :bme680, transport: %{}, sea_level_pa: 100_000]

  test "new/1 create a correct sensor struct" do
    state = Sensor.new(@valid_opts)
    assert %BMP280.Sensor{} = state

    assert Map.keys(state) == [
             :__struct__,
             :calibration,
             :init_fn,
             :last_measurement,
             :read_fn,
             :sea_level_pa,
             :sensor_type,
             :transport
           ]
  end

  test "new/1 raise an error when a required key is missing" do
    assert_raise KeyError, ~r/^key :sensor_type not found in:/, fn ->
      [] |> Sensor.new()
    end

    assert_raise KeyError, ~r/^key :sensor_type not found in:/, fn ->
      @valid_opts |> Keyword.drop([:sensor_type]) |> Sensor.new()
    end

    assert_raise KeyError, ~r/^key :transport not found in:/, fn ->
      @valid_opts |> Keyword.drop([:transport]) |> Sensor.new()
    end

    assert_raise KeyError, ~r/^key :sea_level_pa not found in:/, fn ->
      @valid_opts |> Keyword.drop([:sea_level_pa]) |> Sensor.new()
    end
  end
end
