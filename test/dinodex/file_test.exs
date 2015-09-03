defmodule Dinodex.FileTest do
  use ExUnit.Case

  defp sorted_dinodex(list) do
    Enum.sort_by list, fn(entry) -> entry[:name] end
  end

  test "load dinodex.csv" do
    data = File.stream!("data/dinodex.csv")
           |> Dinodex.File.load
           |> sorted_dinodex

    assert length(data) == 10
    assert hd(data) == %{
      :name => "Albertonykus",
      :period => "Early Cretaceous",
      :continent => "North America",
      :diet => "Insectivore",
      :weight => nil,
      :walking => "Biped",
      :description => "Earliest known Alvarezsaurid.",
    }
  end

  test "load african_dinosaur_export.csv" do
    data = File.stream!("data/african_dinosaur_export.csv")
           |> Dinodex.File.load
           |> sorted_dinodex

    assert length(data) == 7
    assert hd(data) == %{
      :name => "Abrictosaurus",
      :period => "Jurassic",
      :diet => "Herbivore",
      :weight => 100,
      :walking => "Biped",
    }
  end
end
