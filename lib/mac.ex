defmodule MAC do
  @doc """
  Returns the associated vendor of the given MAC if any.
  """
  @spec fetch_vendor(String.t) :: {:ok, String.t} | :error
  defdelegate fetch_vendor(mac), to: MAC.Matcher
end
