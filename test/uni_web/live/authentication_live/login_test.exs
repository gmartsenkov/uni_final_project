defmodule UniWeb.AuthenticationLive.LoginTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  test "it is the log in page", %{conn: conn} do
    {:ok, _login_live, html} = live(conn, Routes.authentication_login_path(conn, :login))

    assert html =~ "Log In"
  end
end
