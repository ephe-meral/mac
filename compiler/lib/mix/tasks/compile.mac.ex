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
      IO.puts("MAC-Table written with #{count_entries(table)} entries")
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

  defp count_entries(table) do
    table |> Enum.reduce(0, fn
      {_, {_, map}}, acc -> acc + Enum.count(map)
      _, acc             -> acc + 1
    end)
  end

  defp build_lookup_table(wireshark_file) do
    wireshark_file
    |> MAC.Parser.parse_wireshark_file
    |> Enum.reduce(%{}, fn
      # the prefix is only 24 bits (min) long - standard key
      {bit_mac, vendor}, acc when bit_size(bit_mac) == 24 ->
        acc |> Map.update(bit_mac, vendor, fn
          sub_match when not is_binary(sub_match) ->
            IO.puts("Discovered shorter key for existing entry at #{inspect bit_mac} for #{vendor} - dropping.")
            sub_match
          _ -> vendor
        end)
      # the prefix is longer, so add it into a list associated with the first 24 bits
      {<<key::bits-size(24), _::bits>> = bit_mac, vendor} = tuple, acc ->
        key_bitsize = bit_size(bit_mac)
        acc |> Map.update(key, {key_bitsize, %{bit_mac => vendor}}, fn
          sub_match when not is_binary(sub_match) -> update_sub_match_map(sub_match, tuple)
          _                                       -> {key_bitsize, %{bit_mac => vendor}}
        end)
    end)
  end

  def update_sub_match_map({key_bitsize, map}, {bit_mac, vendor})
  when bit_size(bit_mac) == key_bitsize do
    {key_bitsize, map |> Map.put(bit_mac, vendor)}
  end
  def update_sub_match_map({key_bitsize, _} = given, {bit_mac, vendor}) when bit_size(bit_mac) < key_bitsize do
    IO.puts("Discovered inconsistent bit-size at #{inspect bit_mac} for #{vendor}: expected #{key_bitsize} but got #{bit_size(bit_mac)} - dropping")
    given
  end
  def update_sub_match_map(given, _), do: given # silently drop more precise keys (b/c its well-known addresses only)
end
