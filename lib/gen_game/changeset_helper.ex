defmodule GenGame.ChangesetHelper do
  @spec traverse_errors(Ecto.Changeset.t()) :: binary()
  def traverse_errors(cs) do
    Enum.map(cs.errors, fn {field, {msg, _values} = _detail} ->
      "field #{field}: #{msg}"
    end)
    |> Enum.join("\n")
  end
end
