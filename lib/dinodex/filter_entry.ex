defmodule Dinodex.FilterEntry do
  def create(name, arg) do
    func = anon(name, arg)
    desc = "#{name} #{arg}"
    {desc, func}
  end

  def anon(name, arg) do
    name_atom = Dinodex.Util.to_atom name, fn ->
      raise UndefinedFunctionError, message: "#{name} filter does not exist"
    end

    arg = Dinodex.Util.to_atom(arg, default: arg)

    anon = fn(dex) -> apply(Dinodex.Filter, name_atom, [dex, arg]) end
    anon.([]) # make sure filters runs properly
    anon
  end

  def apply_all(dex, []), do: dex
  def apply_all(dex, [filter_entry | tail]) do
    {_desc, func} = filter_entry
    func.(dex) |> apply_all(tail)
  end

  def desc({desc, _func}), do: desc
  def func({_desc, func}), do: func
end
