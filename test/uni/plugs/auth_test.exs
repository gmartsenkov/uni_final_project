defmodule Uni.Plugs.AuthTest do
  use UniWeb.ConnCase
  alias Uni.Plugs.Auth

  test "redirects to login screen when user_id is missing from session", %{conn: conn} do
    conn =
      conn
      |> init_test_session(%{})
      |> fetch_flash()
      |> Auth.call()

    assert redirected_to(conn) == "/login"
    assert get_flash(conn, :error) == "Please log in"
    assert conn.halted
  end

  test "does not change the connection when user_id exists in the session", %{conn: conn} do
    conn =
      conn
      |> init_test_session(%{user_id: 1})
      |> fetch_flash()

    resp = conn |> Auth.call()

    assert conn == resp
  end
end
