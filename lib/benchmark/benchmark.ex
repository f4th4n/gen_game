defmodule Benchmark.Benchmark do
  def start() do
  end

  def print_cpu_usage(interval_in_s) do
  end

  def cpu_usage() do
    ~s[grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}']
    |> String.to_charlist()
    |> :os.cmd()
    |> List.to_string()
    |> String.replace("\n", "")
  end
end
