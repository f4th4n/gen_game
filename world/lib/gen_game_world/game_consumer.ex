defmodule GenGameWorld.GameConsumer do
  @moduledoc """
  Process for listening any message that sent by `app`. Currently it's only for creating new game, it will start spawning one `GenGameWorld.Game` process.
  """
  use Broadway

  @hosts [kafka: 9092]
  @topic "gg.game"

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {BroadwayKafka.Producer, [
          hosts: @hosts,
          group_id: "world",
          topics: [@topic],
        ]},
        concurrency: 1
      ],
      processors: [
        default: [
          concurrency: 10
        ]
      ]
    )
  end

  def handle_message(_, %{data: data} = msg, _) do
    data
    |> Jason.decode!()
    |> Map.get("token")
    |> GenGameWorld.Game.new_game()

    msg
  end
end
