defmodule MAC.Matcher do

  # Using the Matcher:
  def company_for_mac(mac) do


  def build_lookup_table(wireshark_file_path) do
    File.read!(wireshark_file_path)
    |> MAC.Parser.parse_wireshark_file
  end
end
