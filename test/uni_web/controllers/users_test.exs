defmodule UniWeb.UsersControllerTest do
  use UniWeb.ConnCase

  describe "autocomplete" do
    test "redirects to login when not logged in", %{conn: conn} do
      conn = get(conn, Routes.users_path(conn, :autocomplete))

      assert get_flash(conn, :error) == "You are not logged in"
      assert redirected_to(conn) == "/login"
    end

    test "it returns correct users", %{conn: conn} do
      user = insert(:user, name: "Bob")
      _jon = insert(:user, name: "Jon Snow")
      rob = insert(:user, name: "Rob Stark")
      arya = insert(:user, name: "Arya Stark")

      conn = init_test_session(conn, %{user_id: user.id})

      conn = get(conn, Routes.users_path(conn, :autocomplete, query: "stark"))

      assert json_response(conn, 200) ==
               Enum.map([rob, arya], fn user ->
                 %{"id" => user.id, "name" => user.name}
               end)
    end
  end
end
