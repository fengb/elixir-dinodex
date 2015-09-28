defmodule Dinodex.Util do
  def str_icontains?(haystack, needle) do
    lcase_check = needle |> to_string |> String.downcase
    String.downcase(haystack) |> String.contains?(lcase_check)
  end
end
