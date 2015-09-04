defmodule Dinodex.Filter do
  @filters %{
    "walking" => :walking,
    "diet"    => :diet,
    "period"  => :period,
    "weight"  => :weight,
  }
  def anon(name, arg) do
    name_atom = @filters[to_string(name)]
    if name_atom do
      fn(dex) -> apply(Dinodex.Filter, name_atom, [dex, arg]) end
    end
  end

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

  def filter(dex, check) do
    Enum.filter dex, &(match(&1, check))
  end

  def match(dino, [{key, checks}]) when is_list(checks) do
    Enum.any? checks, fn(check) -> match(dino, [{key, check}]) end
  end

  def match(dino, [{key, check}]) do
    value = dino[key]
    cond do
      is_function(check) ->
        check.(value)
      is_number(value) ->
        value == as_number(check)
      Regex.regex?(check) ->
        Regex.match? check, value
      is_binary(check) || is_atom(check) ->
        lcase_check = check |> to_string |> String.downcase
        String.downcase(value)
        |> String.contains?(lcase_check)
      true ->
        raise ArgumentError, message: "filter #{key}: #{check} not supported"
    end
  end

  defp as_number(val) when is_number(val), do: val
  defp as_number(val) when is_binary(val), do: String.to_integer(val)
end
