defmodule Dinodex do
  use Application

  def start(_type, args) do
    # TODO: add a real supervisor
    main(args)
  end

  def main(_args) do
    Dinodex.Cmd.repl
    IO.puts "Goodbye!"
  end
end
