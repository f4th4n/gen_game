defmodule GenGame.Storage do
  @moduledoc """
  Distributed storage with auto synchronization.
  """

  defmacro __using__(opts) do
    table = Keyword.get(opts, :table)

    quote do
      use GenServer

      alias Phoenix.PubSub
      alias GenGame.Game.Game

      # also used as pubsub topic
      @table unquote(table)
      @pubsub GenGame.PubSub

      # ----------------------------------------------------------------------------------------------- client

      def start_link(default) do
        GenServer.start_link(__MODULE__, default, name: __MODULE__)
      end

      @doc """
      set a game, distributed to all nodes.
      """
      @spec set(binary(), term()) :: term()
      def set(key, value) when is_binary(key) do
        GenServer.call(__MODULE__, {:set, key, value})
      end

      @doc """
      Check whether a game exist.
      """
      @spec get(binary()) :: term()
      def get(match_id) do
        GenServer.call(__MODULE__, {:get, match_id})
      end

      @spec get_last_match_id() :: term()
      def get_last_match_id() do
        GenServer.call(__MODULE__, :get_last_match_id)
      end

      # ----------------------------------------------------------------------------------------------- server

      def init(init_arg) do
        Phoenix.PubSub.subscribe(@pubsub, topic())
        :ets.new(@table, [:ordered_set, :public, :named_table])
        {:ok, init_arg}
      end

      def handle_info({key, value}, state) when is_binary(key) do
        :ets.insert(@table, {key, value})
        {:noreply, state}
      end

      def handle_call({:set, key, value}, _from, state) do
        PubSub.broadcast(@pubsub, topic(), {key, value})
        {:reply, :ok, state}
      end

      def handle_call({:get, key}, _from, state) do
        {:reply, get_by_key(key), state}
      end

      def handle_call(:get_last_match_id, _from, state) do
        res =
          case :ets.match_object(@table, :_) do
            [] ->
              nil

            entries ->
              entries
              |> Enum.max_by(fn {_, value} -> value.created_at end)
              # Extract the key-value pair
              |> elem(0)
          end

        {:reply, res, state}
      end

      defp get_by_key(key) do
        case :ets.lookup(@table, key) do
          [] -> nil
          [{_key, value}] -> value
        end
      end

      defp topic(), do: Atom.to_string(@table)
    end
  end
end
