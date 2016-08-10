[![Build Status](https://travis-ci.org/ephe-meral/mac.svg?branch=master)](https://travis-ci.org/ephe-meral/mac)
[![Hex.pm](https://img.shields.io/hexpm/l/mac.svg "WTFPL Licensed")](https://github.com/ephe-meral/mac/blob/master/LICENSE)
[![Hex version](https://img.shields.io/hexpm/v/mac.svg "Hex version")](https://hex.pm/packages/mac)
[![Documentation](https://img.shields.io/badge/docs-hexpm-blue.svg)](http://hexdocs.pm/mac/)

# MAC

Parses a MAC-to-vendor database file and builds a search tree from that. This search tree is loaded into memory and can be used via the standard API.

## MAC database

Uses the compiled version from the wireshark project:

https://code.wireshark.org/review/gitweb?p=wireshark.git;a=blob_plain;f=manuf;hb=HEAD

## setup

In your `mix.exs` file:

```elixir
def deps do
  [{:mac, ">= 0.1.0"}]
end
```

Note that the initial compilation might take a few more seconds since it compiles the lookup table.

## usage

```elixir
# standard usage:
MAC.fetch_vendor("00:00:0F:00:00:00")
# => {:ok, "NEXT, INC."}

MAC.fetch_vendor("other stuff or non-existing")
# => :error

# works with different formats by stripping away unexpected chars:
MAC.fetch_vendor(" 00+++00\\\\0F00----00   00  ")
# => {:ok, "NEXT, INC."}

# the parser does also accept bit-masks, so you can also use
MAC.Parser.to_bitstring("00:00:F0/20")
# => <<0, 0, 15::size(4)>>
```

## speed

For a very simple profiling experiment, I used fprof and 10000 lookups of the same MAC with sub-space matching, which took approx. 7600 milliseconds.

If you seem to have problems with the lookup speed, please let me know (create an issue here). I assume that this approach is still faster than calling an external API etc. for this purpose.

## lookup-table structure and assumptions

The table is a max 2 level map with the following assumptions:

- the outer map's keys are the first 3 byte of the MAC address
- the outer map's values are either:
  - a binary with the company name, or
  - a tuple with `{key_bitsize, sub_match_map}`
- a sub-match map key is the entire prefix of any MAC address space with a bitmask biggen than /24 - they are required to be all of the same length per sub-match map (the compiler will notify you if it drops keys b/c of a mismatch)
- the sub-match map's values are the binary vendor names

```elixir
%{<<1, 2, 3>> => "Some Company Inc.",
  <<4, 5, 6>> => {32, %{
    <<4, 5, 6, 7>> => "Another Comp LLC",
    <<4, 5, 6, 8>> => "A 3rd Organisation"}}}
```

## is it any good?

bien sûr.
