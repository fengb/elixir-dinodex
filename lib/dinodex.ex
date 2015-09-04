defmodule Dinodex do
  def main(args) do
    {:ok, pid} = Dinodex.Cmd.start_link

    input = IO.gets("> ") |> String.strip
    reply = Dinodex.Cmd.call(pid, input)
    if reply, do: IO.puts(reply)
    if Process.alive?(pid), do: main(args)
  end
end
