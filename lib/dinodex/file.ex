defmodule Dinodex.File do
  def load(file) do
    CSV.decode(file, headers: true)
    |> Enum.to_list
    |> convert
  end

  defp convert(list) do
    row = hd(list)
    if Dict.has_key?(row, "NAME") do
      convert_dinodex(list)
    else
      convert_african(list)
    end
  end

  defp convert_dinodex(list) do
    Enum.map list, fn(row) ->
      %{
        name: row["NAME"],
        period: row["PERIOD"],
        continent: row["CONTINENT"],
        diet: row["DIET"],
        weight: as_integer(row["WEIGHT_IN_LBS"]),
        walking: row["WALKING"],
        description: row["DESCRIPTION"],
      }
    end
  end

  defp convert_african(list) do
    Enum.map list, fn(row) ->
      %{
        name: row["Genus"],
        period: row["Period"],
        diet: if(as_boolean(row["Carnivore"]), do: "Carnivore", else: "Herbivore"),
        weight: as_integer(row["Weight"]),
        walking: row["Walking"],
      }
    end
  end

  defp as_integer(value) do
    int_result = Integer.parse(value)
    if int_result == :error do
      nil
    else
      elem(int_result, 0)
    end
  end

  defp as_boolean(value), do: value == "Yes"
end
