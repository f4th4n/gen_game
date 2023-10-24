defmodule GenGameWorld.KafkaConsumer do
  use Broadway

  @hosts [kafka: 9092]
  @topic "topic1"

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {BroadwayKafka.Producer, [
          hosts: @hosts,
          group_id: "group_1",
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

  def handle_message(_, message, _) do
    IO.inspect(message, label: "Got message..........")
    message
  end

end