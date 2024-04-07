defmodule GenGame.Helper do
  @doc """

  ## Examples

      iex> GenGame.Helper("rpc, on_create_game")
      [:rpc, :on_create_game]

  """
  @spec str_to_list_of_atom(binary()) :: list(atom())
  def str_to_list_of_atom(str) when is_binary(str) do
    to_atom = &(&1 |> String.trim() |> String.to_atom())
    str |> String.split(",") |> Enum.map(&to_atom.(&1))
  end
end
