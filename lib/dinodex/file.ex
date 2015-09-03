defmodule Dinodex.File do
  def load(file) do
    CSV.decode(file, headers: true)
    |> Enum.map fn(row) ->
         %{
           :name => row["NAME"],
           :period => row["PERIOD"],
           :continent => row["CONTINENT"],
           :diet => row["DIET"],
           :weight => as_integer(row["WEIGHT_IN_LBS"]),
           :walking => row["WALKING"],
           :description => row["DESCRIPTION"],
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
end
