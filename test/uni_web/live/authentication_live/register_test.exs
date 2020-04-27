defmodule UniWeb.AuthenticationLive.RegisterTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  @valid_params %{name: "Bob", email: "bob@snow.com", password: "1234"}
  @invalid_params %{name: nil, email: nil, password: nil}

  test "it is the sign up page", %{conn: conn} do
    {:ok, _register_live, html} = live(conn, Routes.authentication_register_path(conn, :register))

    assert html =~ "Sign Up"
  end

  test "it creates a user", %{conn: conn} do
    {:ok, register_live, _html} = live(conn, Routes.authentication_register_path(conn, :register))

    assert register_live
           |> form("#register-form", user: @invalid_params)
           |> render_change() =~ "can&apos;t be blank"

    {:ok, _, html} =
      register_live
      |> form("#register-form", user: @valid_params)
      |> render_submit()
      |> follow_redirect(conn, Routes.authentication_login_path(conn, :login))

    assert html =~ "User created successfuly"
  end
end
