defmodule UniWeb.AuthenticationControllerTest do
  use UniWeb.ConnCase

  @user_params %{"name" => "Bob", "email" => "bob@jon", "password" => "1234"}

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@user_params)
      |> Map.update("password", "1234", &(Bcrypt.hash_pwd_salt(&1)))
      |> Uni.Users.create_user()

    user
  end

  describe "login" do
    test "fails where params are missing", %{conn: conn} do
      conn = post(conn, Routes.authentication_path(conn, :login))

      assert get_flash(conn, :error) == "User and pass dont match"
      assert redirected_to(conn) == "/login"
    end

    test "fails when user does not exist", %{conn: conn} do
      conn = post(
        conn,
        Routes.authentication_path(conn, :login),
        user: @user_params)

      assert get_flash(conn, :error) == "User and pass dont match"
      assert redirected_to(conn) == "/login"
    end

    test "fails when user exists but the password is wrong", %{conn: conn} do
      user_fixture()
      conn = post(
        conn,
        Routes.authentication_path(conn, :login),
        user: @user_params |> Map.put("password", "invalid"))

      assert get_flash(conn, :error) == "User and pass dont match"
      assert redirected_to(conn) == "/login"
    end

    test "succeeds with correct user and pass", %{conn: conn} do
      user = user_fixture()
      conn = post(
        conn,
        Routes.authentication_path(conn, :login),
        user: @user_params)

      assert get_flash(conn) == %{}
      assert redirected_to(conn) == "/"
      assert conn.private.plug_session == %{"user_id" => user.id}
    end
  end
end
