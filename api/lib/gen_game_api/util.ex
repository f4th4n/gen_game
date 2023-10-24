defmodule GenGameApi.Util do
  def random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length) |> String.downcase()
  end
end
