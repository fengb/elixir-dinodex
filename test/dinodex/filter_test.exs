defmodule Dinodex.FilterTest do
  use ExUnit.Case

  @dino0 %{ walking: "Biped", diet: "Herbivore", period: "Late Jurassic", weight: 2500 }
  @dino1 %{ walking: "Quadraped", diet: "Piscivore", period: "Early Jurassic", weight: 100 }
  @dino2 %{ walking: "Quadraped", diet: "Insectovore", period: "Triassic", weight: 5000 }

  @dex [@dino0, @dino1, @dino2]

  test "walking" do
    biped = Dinodex.Filter.walking(@dex, :biped)
    assert biped == [@dino0]

    quadraped = Dinodex.Filter.walking(@dex, :quadraped)
    assert quadraped == [@dino1, @dino2]
  end

  test "diet" do
    carnivores = Dinodex.Filter.diet(@dex, :carnivore)
    assert carnivores == [@dino1, @dino2]
  end

  test "period" do
    triassic = Dinodex.Filter.period(@dex, :triassic)
    assert triassic == [@dino2]

    jurassic = Dinodex.Filter.period(@dex, :jurassic)
    assert jurassic == [@dino0, @dino1]

    cretaceous = Dinodex.Filter.period(@dex, :cretaceous)
    assert cretaceous == []
  end

  test "weight" do
    big = Dinodex.Filter.weight(@dex, :big)
    assert big == [@dino0, @dino2]

    small = Dinodex.Filter.weight(@dex, :small)
    assert small == [@dino1]
  end

  test "match string" do
    assert Dinodex.Filter.match(@dino0, walking: "Biped")
    refute Dinodex.Filter.match(@dino0, walking: "Quadraped")
  end

  test "match array" do
    assert Dinodex.Filter.match(@dino0, walking: ["Biped", "Quadraped"])
  end
end
