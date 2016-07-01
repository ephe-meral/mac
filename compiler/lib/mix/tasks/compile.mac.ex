Code.require_file("parser.ex", "../lib/mac") # seen from the compiler dir

defmodule Mix.Tasks.Compile.Mac do
  use Mix.Task
  @moduledoc "Compiles wireshark to the internally used lookup table format."
  @recursive true
  # Note that the MAC namespace is spelled 'Mac' here b/c Mix deduces the task name from it

  # Files are seen from the mac (main) dir
  @source_file "db/wireshark_mac_table.dump"
  @dest_file   "db/lookup_table.eterm"

  def run([file]) do
    if rebuild_needed?(file, @dest_file) do
      table = File.read!(file) |> build_lookup_table
      File.write!(@dest_file, table |> :erlang.term_to_binary)
      IO.puts("MAC-Table written with #{Enum.count(table)} entries")
      :ok
    else
      :noop
    end
  end
  def run(_args), do: run([@source_file])

  defp rebuild_needed?(source, dest) do
    if File.exists?(dest) do
      File.stat!(source).mtime >= File.stat!(dest).mtime
    else
      true
    end
  end

  defp build_lookup_table(wireshark_file) do
    wireshark_file
    |> MAC.Parser.parse_wireshark_file
    |> Enum.reduce(%{}, fn
      # the prefix is only 24 bits (min) long - standard key
      {bit_mac, vendor}, acc when bit_size(bit_mac) == 24 ->
        acc |> Map.put(bit_mac, vendor)
      # the prefix is longer, so add it into a list associated with the first 24 bits
      {<<key::bits-size(24), _::bits>>, _} = tuple, acc ->
        acc |> Map.update(key, [tuple], fn
          list when is_list(list) -> list ++ [tuple]
          _                       -> [tuple]
        end)
    end)
  end
end
