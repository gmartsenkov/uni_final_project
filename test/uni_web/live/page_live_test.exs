defmodule UniWeb.PageLiveTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  @user_params %{"name" => "Bob", "email" => "bob@jon", "password" => "1234"}
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@user_params)
      |> Map.update("password", "1234", &Bcrypt.hash_pwd_salt(&1))
      |> Uni.Users.create_user()

    user
  end

  test "disconnected and connected render", %{conn: conn} do
    user = user_fixture()
    conn = init_test_session(conn, %{user_id: user.id})
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Welcome to Phoenix!"
    assert render(page_live) =~ "Welcome to Phoenix!"
  end
end
