defmodule Ada.ShortenerTest do
  use ExUnit.Case, async: true

  alias Ada.Shortener

  test "shorten/1 and resolve/1" do
    assert id = Shortener.shorten("http://example.com")
    assert {:ok, "http://example.com"} == Shortener.resolve(id)
    assert {:error, :not_found} == Shortener.resolve("non-existing-id")
  end

  test "automatic expiry" do
    assert id = Shortener.shorten("http://example.com")
    assert {:ok, "http://example.com"} == Shortener.resolve(id)

    now = DateTime.utc_now()
    url_lifetime = Shortener.url_lifetime()

    # to test expiry, we take the first hour after the url
    # lifetime, so that we're certain it's past the expiry time
    after_url_lifetime =
      now
      |> DateTime.add(url_lifetime + 3600)
      |> Map.merge(%{minute: 0, second: 0})

    Ada.Shortener.handle_info(
      {Ada.PubSub.Broadcast, Ada.Time.Hour, after_url_lifetime},
      url_lifetime
    )

    assert {:error, :not_found} == Shortener.resolve(id)
  end
end
