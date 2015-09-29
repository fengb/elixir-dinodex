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
    try do
      new_dinos = Dinodex.File.load!(filename)
      new_state = %{ state | dex: new_dinos ++ state.dex }
      {:reply, "loaded #{length(new_dinos)} dinos", new_state}
    rescue
      e in File.Error ->
        {:reply, "Cannot load file #{filename}: #{e.reason}", state}
    end
  end

  def handle_call({:unload}, _from, state) do
    new_state = %{ state | dex: [] }
    {:reply, "unloaded #{length(state.dex)} dinos", new_state}
  end

  def handle_call({:filter, name, arg}, _from, state) do
    try do
      filter = create_filter_entry(name, arg)
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
    output = filtered_dex(state) |> Dinodex.Serialize.display
    {:reply, output, state}
  end

  def handle_call({:print, "json"}, _from, state) do
    {:ok, output} = filtered_dex(state) |> Dinodex.Serialize.json
    {:reply, output, state}
  end

  def handle_call({:print, "filters"}, _from, state) do
    output = Enum.map_join(state.filters, "\n", &(&1.desc))
    {:reply, output, state}
  end

  def handle_call({:print, search_name}, _from, state) do
    dino = filtered_dex(state)
           |> Dinodex.Filter.find(name: search_name)
    output = cond do
      dino ->
        Dinodex.Serialize.inspect(dino)
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

  defp filtered_dex(state) do
    Enum.reduce(state.filters, state.dex, &(&1.func.(&2)))
  end

  defp create_filter_entry(name, arg) do
    %{
      func: Dinodex.Filter.anon(name, arg),
      desc: "#{name} #{arg}",
    }
  end
end
