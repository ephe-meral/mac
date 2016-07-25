defmodule MAC.Matcher do
  alias MAC.Compiler

  @source_file Application.app_dir(:mac, "priv") <> "/wireshark_mac_table.dump"
  @external_resource @source_file

  @mac_lookup_table (if File.exists?(@source_file) do
    table = File.read!(@source_file) |> Compiler.build_lookup_table
    IO.puts("MAC-Table created with #{Compiler.count_entries(table)} entries, now compiling...")
    table
  else
    IO.puts("Couldn't find MAC table file at: #{@source_file}")
    %{}
  end)

  def fetch_vendor(mac) when is_binary(mac) do
    {key, bit_mac} =
      case MAC.Parser.to_bitstring(mac) do
        (<<key::bits-size(24), _::bits-size(24)>> = bit_mac) -> {key, bit_mac}
        _                                                    -> {nil, nil}
      end

    case @mac_lookup_table[key] do
      vendor when is_binary(vendor) -> {:ok, vendor}
      {key_bitsize, %{} = sub_match_map} ->
        <<sub_key::bits-size(key_bitsize), _::bits>> = bit_mac
        case sub_match_map[sub_key] do
          vendor when is_binary(vendor) -> {:ok, vendor}
          _                             -> :error
        end
      _ -> :error
    end
  end

  @doc false
  def mac_lookup_table, do: @mac_lookup_table
end
