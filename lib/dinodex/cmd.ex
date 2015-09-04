defmodule Dinodex.Cmd do
  use GenServer

  def start_link do
    :gen_server.start_link(Dinodex.Cmd, [], [])
  end

  def prompt(pid) do
    :gen_server.call(pid, :prompt)
  end

  @calls %{
    {"load",   1} => :load,
    {"unload", 0} => :unload,
    {"filter", 2} => :filter,
    {"reset",  0} => :reset,
    {"print",  0} => :print,
    {"print",  1} => :print,
    {"quit",   0} => :quit,
    {"exit",   0} => :quit,
  }
  def call(pid, cmd_line) do
    [cmd_string | args] = String.split(cmd_line)
    cmd = @calls[{cmd_string, length(args)}]
    if cmd do
      :gen_server.call(pid, List.to_tuple([cmd | args]))
    else
      "Command not found '#{cmd_line}'"
    end
  end

  def init(dex \\ []) do
    state = %{
      dex: dex,
      filters: [],
    }

    {:ok, state}
  end

  def handle_call(:prompt, _from, state) do
    dinos = length(state.dex)
    if state.filters == [] do
      {:reply, "#{dinos}> ", state}
    else
      filtered = filtered_dex(state.dex) |> length
      {:reply, "#{dinos} | #{filtered}> ", state}
    end
  end

  def handle_call({:load, filename}, _from, state) do
    new_dinos = File.stream!(filename) |> Dinodex.File.load
    new_state = %{ state | dex: new_dinos ++ state.dex }
    {:reply, "loaded #{length(new_dinos)}", new_state}
  end

  def handle_call({:unload}, _from, state) do
    new_state = %{ state | dex: [] }
    {:reply, "unloaded #{length(state.dex)}", new_state}
  end

  def handle_call({:filter, command}, _from, state) do
    new_filter = command
    new_state = %{ state | filters: [new_filter | state.filters] }
    {:reply, "added filter", new_state}
  end

  def handle_call({:reset}, _from, state) do
    new_state = %{ state | filters: [] }
    {:reply, "reset filters", new_state}
  end

  def handle_call({:print}, _from, state) do
    output = filtered_dex(state)
             |> Enum.map(&serialize/1)
             |> Enum.join("\n-----\n")
    {:reply, output, state}
  end

  def handle_call({:print, name}, _from, state) do
    name = String.downcase(name)
    dino = filtered_dex(state)
           |> Enum.find fn(dino) ->
                String.downcase(dino.name)
                |> String.contains?(name)
              end
    output = cond do
      dino ->
        serialize(dino)
      List.first(state.filters) ->
        "Dino '#{name}' not found. Maybe it's filtered out?"
      true ->
        "Dino '#{name}' not found."
    end

    {:reply, output, state}
  end

  def handle_call({:quit}, _from, state) do
    {:stop, :quit, state}
  end

  defp serialize(dino) do
    dino
    |> Enum.filter(fn({_key, value}) -> value end)
    |> Enum.map(fn({key, value}) -> "#{key}: #{value}" end)
    |> Enum.join("\n")
  end

  defp filtered_dex(state), do: run_filter(state.dex, state.filters)

  defp run_filter(dex, []), do: dex
  defp run_filter(dex, [filter | tail]) do
    filter.(dex) |> run_filter(tail)
  end
end
