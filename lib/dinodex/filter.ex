defmodule Dinodex.Filter do
  def walking(dex, :biped), do: filter(dex, walking: "Biped")
  def walking(dex, :quadraped), do: filter(dex, walking: "Quadraped")

  def diet(dex, :carnivore), do: filter(dex, diet: ["Carnivore", "Piscivore", "Insectovore"])

  def period(dex, :triassic), do: filter(dex, period: ~r/Triassic$/)
  def period(dex, :jurassic), do: filter(dex, period: ~r/Jurassic$/)
  def period(dex, :cretaceous), do: filter(dex, period: ~r/Cretaceous$/)

  def weight(dex, :big), do: filter(dex, weight: fn(w) -> w > 2000 end)
  def weight(dex, :small), do: filter(dex, weight: fn(w) -> w <= 2000 end)

  def filter(dex, check) do
    Enum.filter dex, fn(dino) -> match(dino, check) end
  end

  def match(dino, [{key, checks}]) when is_list(checks) do
    Enum.any? checks, fn(check) -> match(dino, [{key, check}]) end
  end

  def match(dino, [{key, check}]) do
    cond do
      Regex.regex?(check) ->
        Regex.match? check, dino[key]
      is_function(check) ->
        check.(dino[key])
      true ->
        dino[key] == check
    end
  end
end
