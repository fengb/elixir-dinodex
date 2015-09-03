defmodule Dinodex.FileTest do
  use ExUnit.Case

  test "load dinodex.csv" do
    data = File.stream!("data/dinodex.csv") |> Dinodex.File.load
    assert length(data) == 10

    assert hd(data) == %{
      :name => "Albertosaurus",
      :period => "Late Cretaceous",
      :continent => "North America",
      :diet => "Carnivore",
      :weight => 2000,
      :walking => "Biped",
      :description => "Like a T-Rex but smaller.",
    }
  end
end
