defmodule Dinodex.FilterEntryTest do
  use ExUnit.Case

  @dino0 %{ walking: "Biped", diet: "Herbivore", period: "Late Jurassic", weight: 2500 }
  @dino1 %{ walking: "Quadraped", diet: "Piscivore", period: "Early Jurassic", weight: 100 }
  @dino2 %{ walking: "Quadraped", diet: "Insectovore", period: "Triassic", weight: 5000 }

  @dex [@dino0, @dino1, @dino2]

  test "anon" do
    filter = Dinodex.FilterEntry.anon("walking", "biped")
    assert filter.(@dex) == [@dino0]
  end

  test "anon fails gracefully" do
    assert_raise UndefinedFunctionError, fn ->
      Dinodex.FilterEntry.anon("test", "bar")
    end

    assert_raise UndefinedFunctionError, fn ->
      Dinodex.FilterEntry.anon("missingno", "bar")
    end
  end
end
