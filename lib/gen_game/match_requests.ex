defmodule GenGame.MatchRequests do
  @moduledoc """
  Distributed storage for match requests, using GenGame.Storage.
  """
  @table :match_requests
  use GenGame.Storage, table: @table

  @doc """
  List all match requests.
  """
  def list_requests(), do: lists(:undefined)

  @doc """
  Get a match request by ID.
  """
  def get_request(request_id), do: get(request_id)

  @doc """
  Set a match request by ID.
  """
  def set_request(request_id, data), do: set(request_id, data)


  @doc """
  Delete a match request by ID.
  """
  def delete_request(request_id), do: delete(request_id)

end
