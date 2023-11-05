# $ mix run test/benchmark.exs

alias GenGameWorld.Native.AntiCheat

defmodule AntiCheatEx do
  def validate_player_movement(before_x, before_y, after_x, after_y, speed, timelapse) do
    max_distance = speed * timelapse

    valid_x = abs(after_x - before_x) <= max_distance
    valid_y = abs(after_y - before_y) <= max_distance

    valid_x && valid_y
  end
end

Benchee.run(%{
  "with_nif_rust" => fn ->
    AntiCheat.validate_player_movement(
      :rand.uniform(),
      :rand.uniform(),
      :rand.uniform(),
      :rand.uniform(),
      :rand.uniform(),
      :rand.uniform()
    )
  end,
  "with_elixir" => fn ->
    AntiCheatEx.validate_player_movement(
      :rand.uniform(),
      :rand.uniform(),
      :rand.uniform(),
      :rand.uniform(),
      :rand.uniform(),
      :rand.uniform()
    )
  end
})

# Result:
#
# Name                    ips        average  deviation         median         99th %
# with_nif_rust        1.65 M      604.24 ns  ±5390.04%         505 ns         806 ns
# with_elixir          1.57 M      638.54 ns  ±6372.35%         501 ns         854 ns
# 
# Comparison: 
# with_nif_rust        1.65 M
# with_elixir          1.57 M - 1.06x slower +34.30 ns
