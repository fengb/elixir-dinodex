defmodule Dinodex.Cmd do
  def load(filename) do
    @all_dex = (File.stream!(filename) |> Dinodex.File.load) ++ @all_dex
  end

  def filter(command) do
    @filters << command
  end

  def clear do
    @filters = []
  end

  def print do
    Enum.each filtered_dex, fn(dino) ->
      print(dino)
      IO.puts("-----")
    end
  end

  def print(name) when is_binary(name) do
    regex = Regex.compile(name)
    dino = Enum.find(filtered_dex, fn(dino) -> Regex.match? regex, dino[:name] end)
    cond do
      dino ->
        print(dino)
      List.first(@filters) ->
        IO.puts "Dino #{name} not found. Maybe it's filtered out?"
      true ->
        IO.puts "Dino #{name} not found."
    end
  end

  defp print(dino) do
    Enum.each dino, fn({key, value}) ->
      if value != nil do
        IO.puts("#{key}: #{value}
      end
    end
  end

  defp filtered_dex, do: run_filter(@all_dex, @filters)

  defp run_filter(dex, []), do: dex
  defp run_filter(dex, [filter | tail]) do
    filter.(dex) |> run_filter(tail)
  end
end
