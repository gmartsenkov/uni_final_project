defmodule UniWeb.AuthenticationControllerTest do
  use UniWeb.ConnCase

  @user_params %{"name" => "Bob", "email" => "bob@jon", "password" => "1234"}

  describe "login" do
    test "fails where params are missing", %{conn: conn} do
      conn = post(conn, Routes.authentication_path(conn, :login))

      assert get_flash(conn, :error) == "Email and password do not match"
      assert redirected_to(conn) == "/login"
    end

    test "fails when user does not exist", %{conn: conn} do
      conn =
        post(
          conn,
          Routes.authentication_path(conn, :login),
          user: @user_params
        )

      assert get_flash(conn, :error) == "Email and password do not match"
      assert redirected_to(conn) == "/login"
    end

    test "fails when user exists but the password is wrong", %{conn: conn} do
      insert(:user)

      conn =
        post(
          conn,
          Routes.authentication_path(conn, :login),
          user: @user_params |> Map.put("password", "invalid")
        )

      assert get_flash(conn, :error) == "Email and password do not match"
      assert redirected_to(conn) == "/login"
    end

    test "succeeds with correct user and pass", %{conn: conn} do
      user = insert(:user, email: @user_params["email"])

      conn =
        post(
          conn,
          Routes.authentication_path(conn, :login),
          user: @user_params
        )

      assert get_flash(conn) == %{}
      assert redirected_to(conn) == "/"
      assert conn.private.plug_session == %{"user_id" => user.id}
    end
  end

  describe "logout" do
    test "redirects to login when not logged in", %{conn: conn} do
      conn = get(conn, Routes.authentication_path(conn, :logout))

      assert get_flash(conn, :error) == "Please log in"
      assert redirected_to(conn) == "/login"
    end

    test "it logs out the user", %{conn: conn} do
      user = insert(:user, name: "Bob", email: "bob@bob.com")

      conn = init_test_session(conn, %{user_id: user.id})

      conn = get(conn, Routes.authentication_path(conn, :logout))

      assert get_flash(conn) == %{}
      assert redirected_to(conn) == "/"
      assert conn.private.plug_session == %{}
    end
  end
end
