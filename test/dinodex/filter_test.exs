defmodule Dinodex.FilterTest do
  use ExUnit.Case

  @dino0 %{ walking: "Biped", diet: "Herbivore", period: "Late Jurassic", weight: 2500 }
  @dino1 %{ walking: "Quadraped", diet: "Piscivore", period: "Early Jurassic", weight: 100 }
  @dino2 %{ walking: "Quadraped", diet: "Insectovore", period: "Triassic", weight: 5000 }

  @dex [@dino0, @dino1, @dino2]

  test "walking" do
    biped = @dex |> Dinodex.Filter.walking(:biped)
    assert biped == [@dino0]

    quadraped = @dex |> Dinodex.Filter.walking(:quadraped)
    assert quadraped == [@dino1, @dino2]
  end

  test "diet" do
    carnivores = @dex |> Dinodex.Filter.diet(:carnivore)
    assert carnivores == [@dino1, @dino2]
  end

  test "period" do
    triassic = @dex |> Dinodex.Filter.period(:triassic)
    assert triassic == [@dino2]

    jurassic = @dex |> Dinodex.Filter.period(:jurassic)
    assert jurassic == [@dino0, @dino1]

    cretaceous = @dex |> Dinodex.Filter.period(:cretaceous)
    assert cretaceous == []
  end

  test "weight" do
    big = @dex |> Dinodex.Filter.weight(:big)
    assert big == [@dino0, @dino2]

    small = @dex |> Dinodex.Filter.weight(:small)
    assert small == [@dino1]
  end

  test "match string" do
    assert Dinodex.Filter.match(@dino0, walking: "Biped") == true
    assert Dinodex.Filter.match(@dino0, walking: "Quadraped") == false
  end

  test "match array" do
    assert Dinodex.Filter.match(@dino0, walking: ["Biped", "Quadraped"]) == true
  end

  test "anon" do
    filter = Dinodex.Filter.anon("walking", "biped")
    assert filter.(@dex) == [@dino0]
  end
end
