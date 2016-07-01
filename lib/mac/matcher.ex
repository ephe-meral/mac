defmodule MAC.Matcher do

  @mac_lookup_table (if File.exists?("db/lookup_table.eterm") do
    File.read!("db/lookup_table.eterm") |> :erlang.binary_to_term
  else
    %{}
  end)

  # Using the Matcher:
  def company_for_mac(mac) when is_binary(mac) do
    (<<key::bits-size(24), _::bits>> = bit_mac) =
      MAC.Parser.to_bitstring(mac)

    case @mac_lookup_table[key] do
      vendor when is_binary(vendor) -> {:ok, vendor}
      entry when is_list(entry) ->
        entry
        |> Enum.find(:error, &match_prefix(&1, bit_mac))
        |> case do
          {_, vendor} -> {:ok, vendor}
          _           -> :error
        end
      _ -> :error
    end
  end

  defp match_prefix({prefix, _}, mac) do
    size = bit_size(prefix)
    case mac do
      <<^prefix::bits-size(size), _::bits>> -> true
      _                                     -> false
    end
  end

  def build_lookup_table(wireshark_file_path) do
    File.read!(wireshark_file_path)
    |> MAC.Parser.parse_wireshark_file
    |> Enum.reduce(%{}, fn
      # the prefix is only 24 bits (min) long - standard key
      {bit_mac, vendor}, acc when bit_size(bit_mac) == 24 ->
        acc |> Map.put(bit_mac, vendor)
      # the prefix is longer, so add it into a list associated with the first 24 bits
      {<<key::bits-size(24), _::bits>>, _} = tuple, acc ->
        acc |> Map.update(key, [], fn
          list when is_list(list) -> list ++ [tuple]
          _                       -> [tuple]
        end)
    end)
  end
end
