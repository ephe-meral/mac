defmodule MAC.ParserTest do
  use ExUnit.Case, async: true
  import MAC.Parser

  @bin <<1::8, 2::8, 3::8, 253::8, 254::8, 255::8>>

  test "mac: any non-sized format" do
    assert to_bitstring("01:02:03:FD:FE:FF") == @bin
    assert to_bitstring("XY0102ZZ???03:FD-fe-FF") == @bin
  end

  test "mac: any sized format" do
    size = 36
    <<smaller::bits-size(size), _::bits>> = @bin
    assert to_bitstring("01:02:03:FD:FE:FF/#{size}") == smaller
    assert to_bitstring("XY0102ZZ???03:FD-fe-FFhijklm/mnop#{size}") == smaller
  end

  test "wireshark line" do
    size = 36
    <<smaller::bits-size(size), _::bits>> = @bin
    <<key::bits-size(24), _::bits>> = @bin

    assert parse_wireshark_line("01:02:03:FD:FE:FF/#{size}\tAComp\t# A Company, Inc.") ==
      {smaller, "A Company, Inc."}

    assert parse_wireshark_line("01:02:03\tAComp") ==
      {key, "AComp"}
  end

  test "wireshark lines" do
    size = 36
    <<smaller::bits-size(size), _::bits>> = @bin
    <<key::bits-size(24), _::bits>> = @bin

    file = """
    #Some comment
    01:02:03:FD:FE:FF/#{size}\tAComp\t# A Company, Inc.

    01:02:03\tAComp

    # another comment
    """

    assert parse_wireshark_file(file) == [
      {smaller, "A Company, Inc."},
      {key, "AComp"}]
  end
end
