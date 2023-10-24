defmodule GenGameAppTest do
  use ExUnit.Case
  doctest GenGameApp

  test "greets the world" do
    assert GenGameApp.hello() == :world
  end
end
