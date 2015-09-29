defmodule Dinodex.Util do
  def to_atom(val, default: default), do: to_atom(val, fn -> default end)
  def to_atom(val, on_error) do
    lval = String.downcase(val)
    try do
      String.to_existing_atom(lval)
    rescue  _e in ArgumentError ->
      on_error.()
    end
  end

  def str_icontains?(haystack, needle) do
    lcase_check = needle |> to_string |> String.downcase
    String.downcase(haystack) |> String.contains?(lcase_check)
  end
end
