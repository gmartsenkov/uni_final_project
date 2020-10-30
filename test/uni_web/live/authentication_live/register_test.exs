defmodule UniWeb.AuthenticationLive.RegisterTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  @valid_params %{name: "Bob", email: "bob@snow.com", password: "1234"}
  @invalid_params %{name: nil, email: nil, password: nil}

  @tag :skip
  test "it is the sign up page", %{conn: conn} do
    {:ok, _register_live, html} = live(conn, Routes.authentication_register_path(conn, :register))

    assert html =~ "Sign Up"
  end

  @tag :skip
  test "it creates a user", %{conn: conn} do
    {:ok, register_live, _html} = live(conn, Routes.authentication_register_path(conn, :register))

    assert register_live
           |> form("#register-form", user: @invalid_params)
           |> render_change() =~ "can&apos;t be blank"

    {:ok, conn} =
      register_live
      |> form("#register-form", user: @valid_params)
      |> render_submit()
      |> follow_redirect(conn, Routes.authentication_path(conn, :login))

    assert conn.resp_body =~ "Log In"
    assert conn.resp_body =~ "User created successfuly"
  end
end
