defmodule Dinodex.Cmd do
  use GenServer

  def repl do
    {:ok, pid} = Dinodex.Cmd.start_link
    repl(pid)
  end

  defp repl(pid) do
    prompt = Dinodex.Cmd.prompt(pid)
    input = IO.gets(prompt)

    reply = Dinodex.Cmd.call(pid, String.strip(input))
    if reply, do: IO.puts(reply)
    if Process.alive?(pid), do: repl(pid)
  end

  def start_link do
    :gen_server.start_link(Dinodex.Cmd, [], [])
  end

  def prompt(pid) do
    :gen_server.call(pid, :prompt)
  end

  def call(pid, cmd_line) do
    command = parse_command(cmd_line)
    if command do
      :gen_server.call(pid, command)
    else
      "Command not found '#{cmd_line}'\n\n#{help_text}"
    end
  end

  @commands [
    ["help"],
    ["load", "<filename>"],
    ["filter", "<filter>", "<value>"],
    ["unload"],
    ["reset"],
    ["print"],
    ["print", "filters"],
    ["print", "<name>"],
    ["quit"]
  ]
  def parse_command(cmd_line) do
    [cmd | args] = String.split(cmd_line)
    found = Enum.find @commands, fn([search_cmd | search_args]) ->
      search_cmd == cmd && length(search_args) == length(args)
    end

    if found do
      cmd_atom = String.to_existing_atom(cmd)
      List.to_tuple([cmd_atom | args])
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
    {:reply, "unloaded #{length(state.dex)} dinos", new_state}
  end

  def handle_call({:filter, name, arg}, _from, state) do
    try do
      filter_func = Dinodex.Filter.anon(name, arg)
      filter_name = "#{name} #{arg}"
      filter = {filter_name, filter_func}
      new_state = %{ state | filters: [filter | state.filters] }
      {:reply, "added filter", new_state}
    rescue _e in UndefinedFunctionError ->
      {:reply, "cannot add filter #{name} #{arg}", state}
    end
  end

  def handle_call({:reset}, _from, state) do
    new_state = %{ state | filters: [] }
    {:reply, "reset filters", new_state}
  end

  def handle_call({:print}, _from, state) do
    output = filtered_dex(state)
             |> Enum.map_join("\n-----\n", &serialize/1)
    {:reply, output, state}
  end

  def handle_call({:print, "filters"}, _from, state) do
    output = Enum.map_join(state.filters, "\n", &filter_name/1)
    {:reply, output, state}
  end

  def handle_call({:print, search_name}, _from, state) do
    dino = filtered_dex(state)
           |> Enum.find(&(Dinodex.Util.str_icontains?(&1.name, search_name)))
    output = cond do
      dino ->
        serialize(dino)
      hd(state.filters) ->
        "Dino '#{search_name}' not found. Maybe it's filtered out?"
      true ->
        "Dino '#{search_name}' not found."
    end

    {:reply, output, state}
  end

  def handle_call({:quit}, _from, state) do
    {:stop, :normal, nil, state}
  end

  defp help_text do
    command_help = Enum.map_join @commands, "\n", &("  " <> Enum.join(&1, " "))
    "Available commands:\n#{command_help}"
  end

  defp serialize(dino) do
    dino
    |> Enum.filter(fn({_key, value}) -> value end)
    |> Enum.map_join("\n", fn({key, value}) -> "#{key}: #{value}" end)
  end

  defp filtered_dex(state) do
    run_filters(state.dex, Enum.map(state.filters, &filter_func/1))
  end

  defp run_filters(dex, []), do: dex
  defp run_filters(dex, [func | tail]) do
    func.(dex) |> run_filters(tail)
  end

  defp filter_name({name, _func}), do: name
  defp filter_func({_name, func}), do: func
end
