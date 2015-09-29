defmodule Dinodex.FileTest do
  use ExUnit.Case

  test "load dinodex.csv" do
    data = Dinodex.File.load!("data/dinodex.csv")
           |> Enum.sort_by &(&1.name)

    assert length(data) == 10
    assert hd(data) == %{
      name: "Albertonykus",
      period: "Early Cretaceous",
      continent: "North America",
      diet: "Insectivore",
      weight: nil,
      walking: "Biped",
      description: "Earliest known Alvarezsaurid.",
    }
  end

  test "load african_dinosaur_export.csv" do
    data = Dinodex.File.load!("data/african_dinosaur_export.csv")
           |> Enum.sort_by &(&1.name)

    assert length(data) == 7
    assert hd(data) == %{
      name: "Abrictosaurus",
      period: "Jurassic",
      diet: "Herbivore",
      weight: 100,
      walking: "Biped",
    }
  end
end
