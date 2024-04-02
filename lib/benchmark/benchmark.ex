defmodule Benchmark.Benchmark do
  @moduledoc """
  To collect cpu and memory usage. Use together with Tsung.
  """
  use Agent

  require Logger

  def start_benchmark() do
    IO.puts(
      "start collecting cpu & memory usage...\nto stop, call Benchmark.Benchmark.stop_benchmark()"
    )

    ticker = Task.async(&tick/0)
    Agent.start_link(fn -> %{ticker: ticker, usages: []} end, name: __MODULE__)
    :ok
  end

  def stop_benchmark() do
    %{usages: usages, ticker: ticker} = Agent.get(__MODULE__, & &1)
    benchmark_file = "/tmp/gen_game_benchmark_" <> Ecto.UUID.generate()
    File.write!(benchmark_file, Enum.join(usages, "\n"))
    IO.puts("write resource usages to #{benchmark_file}")
    nil = Task.shutdown(ticker)
    Agent.stop(__MODULE__)
  end

  def tick() do
    %{
      memory_usage: memory_usage,
      memory_usage_unit: memory_usage_unit,
      cpu_load: cpu_load,
      local_time: local_time
    } = get_resource_usage()

    resource_data =
      "[#{local_time}] cpu load (1m): #{cpu_load}, memory: #{memory_usage} #{memory_usage_unit}"

    Agent.update(__MODULE__, &Map.put(&1, :usages, &1.usages ++ [resource_data]))
    IO.puts(resource_data)

    :timer.sleep(1000)
    tick()
  end

  defp get_resource_usage() do
    pad = &(&1 |> Integer.to_string() |> String.pad_leading(2, "0"))

    timestamp = :os.system_time(:millisecond)
    {memory_usage, memory_usage_unit} = memory_usage()
    cpu_load = cpu_load()
    {_, {h, m, s}} = :erlang.localtime()

    %{
      memory_usage: memory_usage,
      memory_usage_unit: memory_usage_unit,
      cpu_load: cpu_load,
      local_time: "#{pad.(h)}:#{pad.(m)}:#{pad.(s)}",
      timestamp: timestamp
    }
  end

  defp cpu_load() do
    # cpu load avg in a minute
    ~s[cat /proc/loadavg]
    |> String.to_charlist()
    |> :os.cmd()
    |> List.to_string()
    |> String.split(" ")
    |> List.first()
  end

  defp memory_usage() do
    {:memory, size} =
      :code_server
      |> Process.whereis()
      |> :erlang.process_info(:memory)

    usage_in_mb = size / 1024 / 1024
    {usage_in_mb, "MB"}
  end
end
