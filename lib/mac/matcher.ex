defmodule MAC.Matcher do
  @mac_lookup_table (if File.exists?("db/lookup_table.eterm") do
    File.read!("db/lookup_table.eterm") |> :erlang.binary_to_term
  else
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
