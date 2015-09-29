defmodule Dinodex do
  def main(_args) do
    Dinodex.Cmd.repl
    IO.puts "Goodbye!"
  end
end
