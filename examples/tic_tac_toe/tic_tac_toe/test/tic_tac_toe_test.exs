defmodule TicTacToeTest do
  use ExUnit.Case
  doctest TicTacToe

  test "greets the world" do
    assert TicTacToe.hello() == :world
  end
end
