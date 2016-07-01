defmodule MAC.MatcherTest do
  use ExUnit.Case, async: true

  test "lookup of simple MAC" do
    assert MAC.Matcher.fetch_vendor("00:00:0F:00:00:00") == {:ok, "NEXT, INC."}
    assert MAC.Matcher.fetch_vendor("00:00:0F:12:34:56") == {:ok, "NEXT, INC."}
    assert MAC.Matcher.fetch_vendor("00:00:0F:FF:FF:FF") == {:ok, "NEXT, INC."}
  end

  test "lookup of non-standard entry" do
    assert MAC.Matcher.fetch_vendor("00:00:10:00:00:00") == {:ok, "Hughes"}
    assert MAC.Matcher.fetch_vendor("00:00:10:12:34:56") == {:ok, "Hughes"}
    assert MAC.Matcher.fetch_vendor("00:00:10:FF:FF:FF") == {:ok, "Hughes"}
  end

  test "lookup of sub-prefix match" do
    # 36 bit mask
    assert MAC.Matcher.fetch_vendor("00:1B:C5:01:10:00") == {:ok, "OOO NPP Mera"}
    assert MAC.Matcher.fetch_vendor("00:1B:C5:01:11:23") == {:ok, "OOO NPP Mera"}
    assert MAC.Matcher.fetch_vendor("00:1B:C5:01:1F:FF") == {:ok, "OOO NPP Mera"}
  end

  test "exact matches" do
    assert MAC.Matcher.fetch_vendor("01-DD-00-FF-FF-FF") == {:ok, "Ungermann-Bass-boot-me-requests"}
  end

  test "non-matching stuff" do
    assert MAC.Matcher.fetch_vendor("01-DD-00-FF-FF-FF/13") == :error
  end
end
