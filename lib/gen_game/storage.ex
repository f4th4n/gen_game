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
      List all entries in the storage.
      with query pattern to filter results.
      query is :ets:match_object query pattern.
      """
      @spec lists(term()) :: [term()]
      def lists(query \\ :undefined) do
        GenServer.call(__MODULE__, {:lists, query})
      end

      @doc """
      get data by id
      """
      @spec get(binary()) :: term()
      def get(id) do
        GenServer.call(__MODULE__, {:get, id})
      end

      @doc """
      set a data, distributed to all nodes.
      """
      @spec set(binary(), term()) :: term()
      def set(key, value) when is_binary(key) do
        GenServer.call(__MODULE__, {:set, key, value})
      end

      @doc """
      Delete a data.
      """
      @spec delete(binary()) :: :ok
      def delete(id) do
        GenServer.call(__MODULE__, {:delete, id})
      end

      # ----------------------------------------------------------------------------------------------- server

      def init(init_arg) do
        Phoenix.PubSub.subscribe(@pubsub, topic())
        :ets.new(@table, [:ordered_set, :public, :named_table])
        {:ok, init_arg}
      end

      def handle_info({:set, key, value}, state) when is_binary(key) do
        :ets.insert(@table, {key, value})
        {:noreply, state}
      end

      def handle_info({:delete, key}, state) when is_binary(key) do
        :ets.delete(@table, key)
        {:noreply, state}
      end

      def handle_call({:lists, query}, _from, state) do
        entries = case query do
          :undefined -> :ets.match_object(@table, :_)
          _ -> :ets.match_object(@table, query)
        end
        {:reply, entries, state}
      end

      def handle_call({:get, key}, _from, state) do
        {:reply, get_by_key(key), state}
      end

      def handle_call({:set, key, value}, _from, state) do
        PubSub.broadcast(@pubsub, topic(), {:set, key, value})
        {:reply, :ok, state}
      end

      def handle_call({:delete, key}, _from, state) do
        PubSub.broadcast(@pubsub, topic(), {:delete, key})
        {:reply, :ok, state}
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
