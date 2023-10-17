defmodule JumpaAppTest do
  use ExUnit.Case
  doctest JumpaApp

  test "greets the world" do
    assert JumpaApp.hello() == :world
  end
end
