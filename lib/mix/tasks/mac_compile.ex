# Note that the MAC namespace is spelled 'Mac' here b/c Mix deduces the task name from it
defmodule Mix.Tasks.Mac.Compile do
  use Mix.Task
  @moduledoc """
  Compiles a given wireshark MAC address to vendor association to an
  erlang-compatible data definition of the datatype that can be used
  with the MAC.lookup function.
  """
  @shortdoc "Compiles wireshark to the internally used lookup table format."

  def run([file]) do
    table = MAC.Matcher.build_lookup_table(file)
    File.write!("db/lookup_table.eterm", table |> :erlang.term_to_binary)
    IO.puts("Table written with #{Enum.count(table)} entries")
  end
  def run(_args), do: IO.puts("Args must be: wireshark_file")
end
