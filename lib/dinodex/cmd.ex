defmodule Dinodex.Cmd do
  use GenServer

  def start_link do
    :gen_server.start_link(Dinodex.Cmd, [], [])
  end

  def call(pid, cmd_line) do
    :gen_server.call(pid, cmd_line)
  end

  def init(dex \\ []) do
    state = %{
      dex: dex,
      filters: [],
    }

    {:ok, state}
  end

  @calls %{
    "load"   => :load,
    "filter" => :filter,
    "clear"  => :clear,
    "print"  => :print,
    "quit"   => :quit,
  }
  def handle_call(:prompt, _from, state) do
    dinos = length(state.dex)
    {:reply, "#{dinos}> ", state}
  end

  def handle_call(cmd_line, _from, state) do
    [cmd_string | args] = String.split(cmd_line)
    cmd = @calls[cmd_string]
    if cmd do
      apply(Dinodex.Cmd, cmd, [state] ++ args)
    else
      {:reply, "Command not found '#{cmd_line}'", state}
    end
  end

  def load(state, filename) do
    new_dinos = File.stream!(filename) |> Dinodex.File.load
    IO.inspect new_dinos
    new_state = %{
      dex: new_dinos ++ state[:dex],
      filters: state[:filters],
    }

    {:reply, "loaded #{filename}", new_state}
  end

  def filter(state, command) do
    new_filter = nil
    new_state = %{
      dex: state[:dex],
      filters: [] ++ state[:filters],
    }

    {:reply, "added filter", new_state}
  end

  def clear(state) do
    new_state = %{
      dex: state[:dex],
      filters: [],
    }

    {:reply, "cleared all filters", new_state}
  end

  def print(state) do
    output = filtered_dex(state)
             |> Enum.map(&serialize/1)
             |> Enum.join("\n-----\n")
    {:reply, output, state}
  end

  def print(state, name) do
    regex = Regex.compile(name)
    dino = filtered_dex(state)
           |> Enum.find(fn(dino) -> Regex.match? regex, dino[:name] end)
    output = cond do
      dino ->
        serialize(dino)
      List.first(state[:filters]) ->
        "Dino #{name} not found. Maybe it's filtered out?"
      true ->
        "Dino #{name} not found."
    end

    {:reply, output, state}
  end

  def quit(state) do
    {:stop, :quit, state}
  end

  defp serialize(dino) do
    dino
    |> Enum.filter(fn({_key, value}) -> value end)
    |> Enum.map(fn({key, value}) -> "#{key}: #{value}" end)
    |> Enum.join("\n")
  end

  defp filtered_dex(state), do: run_filter(state[:dex], state[:filters])

  defp run_filter(dex, []), do: dex
  defp run_filter(dex, [filter | tail]) do
    filter.(dex) |> run_filter(tail)
  end
end
