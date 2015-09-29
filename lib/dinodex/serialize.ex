defmodule Dinodex.Serialize do
  def display(dinos) when is_list(dinos) do
    Enum.map_join(dinos, "\n-----\n", &display/1)
  end

  def display(dino) do
    dino
    |> Enum.filter(fn({_key, value}) -> value end)
    |> Enum.map_join("\n", fn({key, value}) -> "#{key}: #{value}" end)
  end

  def json(dinos), do: JSON.encode(dinos)
end
