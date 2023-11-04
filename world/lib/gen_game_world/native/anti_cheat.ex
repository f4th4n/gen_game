defmodule GenGameWorld.Native.AntiCheat do
  use Rustler, otp_app: :gen_game_world, crate: "anti_cheat"

  @doc """
		check if player movement is valid by calculating position, speed, and timelapse

	  ## Examples

	    iex> GenGameWorld.Native.AntiCheat.validate_player_movement(1.0, 1.0, 1.0, 1.0, 3.0, 1.0)
	    true

	    iex> GenGameWorld.Native.AntiCheat.validate_player_movement(1.0, 10.0, 1.0, 1.0, 3.0, 1.0)
	    false
  """
  def validate_player_movement(_before_x, _before_y, _after_x, _after_y, _speed, _timelapse), do: error()

  defp error(), do: :erlang.nif_error(:nif_not_loaded)
end
