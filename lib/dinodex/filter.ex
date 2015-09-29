defmodule Dinodex.Filter do
  def walking(dex, :biped), do: walking(dex, "Biped")
  def walking(dex, :quadraped), do: walking(dex, "Quadraped")
  def walking(dex, value), do: filter(dex, walking: value)

  def diet(dex, :carnivore), do: diet(dex, ["Carnivore", "Piscivore", "Insectovore"])
  def diet(dex, value), do: filter(dex, diet: value)

  def period(dex, :triassic), do: period(dex, "triassic")
  def period(dex, :jurassic), do: period(dex, "jurassic")
  def period(dex, :cretaceous), do: period(dex, "cretaceous")
  def period(dex, value), do: filter(dex, period: value)

  def weight(dex, :big), do: weight(dex, &(&1 > 2000))
  def weight(dex, :small), do: weight(dex, &(&1 <= 2000))
  def weight(dex, value), do: filter(dex, weight: value)

  def filter(dex, check), do: Enum.filter(dex, &match(&1, check))

  def find(dex, check), do: Enum.find(dex, &match(&1, check))

  def match(dino, [{key, checks}]) when is_list(checks), do: Enum.any?(checks, &(match(dino, [{key, &1}])))
  def match(dino, [{key, check}]) when is_function(check), do: check.(dino[key])
  def match(dino, [{key, check}]) when is_number(check), do: dino[key] == as_number(check)
  def match(dino, [{key, check}]) when is_binary(check), do: Dinodex.Util.str_icontains?(dino[key], check)
  def match(_dino, [{key, check}]) do
    raise ArgumentError, message: "filter #{key}: #{check} not supported"
  end

  defp as_number(val) when is_number(val), do: val
  defp as_number(val) when is_binary(val), do: String.to_integer(val)
end
