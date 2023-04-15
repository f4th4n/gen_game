defmodule JumpaWorldTest do
  use ExUnit.Case
  doctest JumpaWorld

  test "greets the world" do
    assert JumpaWorld.hello() == :world
  end
end
