defmodule GenGame.Documentation do
  def path(path) do
    base_url = Application.get_env(:gen_game, :doc_url)
    "#{base_url}#{path}"
  end
end
