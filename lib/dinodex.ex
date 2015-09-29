defmodule Dinodex do
  def main(args) do
    commands = Enum.map args, &({:load, &1})
    Dinodex.Cmd.repl(commands)
    IO.puts "Goodbye!"
  end
end
