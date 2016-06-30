defmodule MAC.Parser do

  @doc "Returns a list of tuples with {bitstring-mac (or part), company}"
  def parse_wireshark_file(text) do
    text
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> String.strip(line) end)
    |> Enum.filter(fn line -> not String.starts_with?(line, "#") end)
    |> Enum.map(&parse_wireshark_line/1)
    |> Enum.filter(fn x -> not is_nil(x) end)
  end

  @doc "Returns a tuple with {bitstring-mac (or part), company}"
  def parse_wireshark_line(line) do
    case String.split(line, ~r/\s/) do
      [mac, _, "#" | name] -> {mac |> to_bitstring, name |> Enum.join(" ")}
      [mac, company]       -> {mac |> to_bitstring, company}
      _                    -> nil
    end
    |> case do
      {<<_::bits>>, _} = result -> result
      _                         -> nil
    end
  end

  @doc "Returns a bitstring or nil"
  def to_bitstring(mac) do
    filtered_mac = mac |> String.replace(~r([^a-fA-F\d/]), "") |> String.upcase
    case Regex.run(~r[(\w*)/?(\w*)], filtered_mac) do
      [_, hex_mac, ""]   -> hex_to_bitstring(hex_mac)
      [_, hex_mac, mask] -> hex_to_bitstring(hex_mac, mask |> String.to_integer)
    end
  end

  defp hex_to_bitstring(hex, take \\ nil) do
    take = take || String.length(hex) * 4
    case Base.decode16(hex) do
      {:ok, <<val::bits-size(take), _::bits>>} -> val
      _                                        -> nil
    end
  end
end

