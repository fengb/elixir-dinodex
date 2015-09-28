defmodule Dinodex.Cmd do
  use GenServer

  def repl do
    {:ok, pid} = Dinodex.Cmd.start_link
    repl(pid)
  end

  defp repl(pid) do
    prompt = Dinodex.Cmd.prompt(pid)
    input = IO.gets(prompt) |> String.strip

    reply = Dinodex.Cmd.call(pid, input)
    if reply, do: IO.puts(reply)
    if Process.alive?(pid), do: repl(pid)
  end

  def start_link do
    :gen_server.start_link(Dinodex.Cmd, [], [])
  end

  def prompt(pid) do
    :gen_server.call(pid, :prompt)
  end

  @calls %{
    {"help",   0} => :help,
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
      "Command not found '#{cmd_line}'\n\n#{help_text}"
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
      filtered = filtered_dex(state) |> length
      {:reply, "#{dinos} | #{filtered}> ", state}
    end
  end

  def handle_call({:help}, _from, state) do
    {:reply, help_text, state}
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

  def handle_call({:filter, name, arg}, _from, state) do
    new_filter = Dinodex.Filter.anon(name, arg)
    if is_function(new_filter) do
      new_state = %{ state | filters: [new_filter | state.filters] }
      {:reply, "added filter", new_state}
    else
      {:reply, "cannot add filter #{name} #{arg}", state}
    end
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

  def handle_call({:print, search_name}, _from, state) do
    dino = filtered_dex(state)
           |> Enum.find(&(Dinodex.Util.str_icontains?(&1.name, search_name)))
    output = cond do
      dino ->
        serialize(dino)
      List.first(state.filters) ->
        "Dino '#{search_name}' not found. Maybe it's filtered out?"
      true ->
        "Dino '#{search_name}' not found."
    end

    {:reply, output, state}
  end

  def handle_call({:quit}, _from, state) do
    {:stop, :quit, state}
  end

  defp help_text do
    command_help = @calls
                   |> Enum.map(&help_line/1)
                   |> Enum.join("\n")
    "Available commands:\n#{command_help}"
  end

  defp help_line({{name, 0}, _sym}), do: "  #{name}"
  defp help_line({{name, arity}, _sym}) do
    name_desc = String.ljust(name, 6)
    arity_desc = (1..arity)
                 |> Enum.map(&(" arg#{&1}"))
                 |> Enum.join
    "  #{name_desc}#{arity_desc}"
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
