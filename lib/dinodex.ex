defmodule Dinodex do
  def main(_args) do
    {:ok, pid} = Dinodex.Cmd.start_link
    loop(pid)
  end

  defp loop(pid) do
    prompt = Dinodex.Cmd.prompt(pid)
    input = IO.gets(prompt) |> String.strip

    reply = Dinodex.Cmd.call(pid, input)
    if reply, do: IO.puts(reply)
    if Process.alive?(pid), do: loop(pid)
  end
end
