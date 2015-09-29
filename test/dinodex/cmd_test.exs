defmodule Dinodex.CmdTest do
  use ExUnit.Case

  test "parse_command" do
    assert Dinodex.Cmd.parse_command("quit") == {:quit}
    assert Dinodex.Cmd.parse_command("print") == {:print}
    assert Dinodex.Cmd.parse_command("print filters") == {:print, "filters"}
    assert Dinodex.Cmd.parse_command("print foobar") == {:print, "foobar"}
    assert Dinodex.Cmd.parse_command("filter a b") == {:filter, "a", "b"}
  end

  test "parse_command illegal command" do
    refute Dinodex.Cmd.parse_command("missing")
    refute Dinodex.Cmd.parse_command("filter")
    refute Dinodex.Cmd.parse_command("filter one-arg")
  end
end
