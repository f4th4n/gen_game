defmodule GenGameWeb.PingChannelTest do
  use GenGameWeb.ChannelCase

  test "ping replies with status ok" do
    {:ok, _, socket} =
      GenGameWeb.GameSocket
      |> socket()
      |> subscribe_and_join(GenGameWeb.PingChannel, "ping", %{})

    ref = push(socket, "send_ping", %{})
    assert_reply ref, :ok, %{}
  end
end
