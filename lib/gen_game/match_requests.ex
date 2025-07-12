defmodule GenGame.MatchRequests do
  @moduledoc """
  Distributed storage for match requests, using GenGame.Storage.
  """
  @table :match_requests
  use GenGame.Storage, table: @table

  @doc """
  Set a match request by ID.
  """
  def set_request(request_id, data), do: set(request_id, data)

  @doc """
  Get a match request by ID.
  """
  def get_request(request_id), do: get(request_id)


  @doc """
  Delete a match request by ID.
  """
  def delete_request(request_id), do: delete(request_id)

  @doc """
  List all match requests.
  """
  def list_requests() do
    :ets.tab2list(@table)
    |> Enum.map(fn {id, req} -> {id, req} end)
  end
end
