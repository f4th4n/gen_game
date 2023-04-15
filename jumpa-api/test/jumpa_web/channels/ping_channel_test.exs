defmodule JumpaWeb.PingChannelTest do
  use JumpaWeb.ChannelCase

  test "ping replies with status ok" do
    {:ok, _, socket} =
      JumpaWeb.GameSocket
      |> socket()
      |> subscribe_and_join(JumpaWeb.PingChannel, "ping", %{})

    ref = push(socket, "send_ping", %{})
    assert_reply ref, :ok, %{}
  end
end
