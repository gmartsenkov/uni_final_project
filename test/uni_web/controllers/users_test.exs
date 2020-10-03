defmodule UniWeb.UsersControllerTest do
  use UniWeb.ConnCase

  describe "autocomplete" do
    test "redirects to login when not logged in", %{conn: conn} do
      conn = get(conn, Routes.users_path(conn, :autocomplete))

      assert get_flash(conn, :error) == "Please log in"
      assert redirected_to(conn) == "/login"
    end

    test "it returns correct users", %{conn: conn} do
      user = insert(:user, name: "Bob", email: "bob@bob.com")
      _jon = insert(:user, name: "Jon Snow", email: "jon@snow.com")
      rob = insert(:user, name: "Rob Stark", email: "rob@stark.com")
      arya = insert(:user, name: "Arya Stark", email: "arya@stark.com")

      conn = init_test_session(conn, %{user_id: user.id})

      conn = get(conn, Routes.users_path(conn, :autocomplete, query: "stark"))

      assert json_response(conn, 200) ==
               Enum.map([rob, arya], fn user ->
                 %{"id" => user.id, "name" => user.name}
               end)
    end

    test "it returns an empty array when less than 3", %{conn: conn} do
      user = insert(:user, name: "Bob", email: "bob@bob.com")
      insert(:user, name: "Jon Snow", email: "jon@snow.com")
      insert(:user, name: "Rob Stark", email: "rob@stark.com")
      insert(:user, name: "Arya Stark", email: "arya@stark.com")

      conn = init_test_session(conn, %{user_id: user.id})

      conn = get(conn, Routes.users_path(conn, :autocomplete, query: "st"))

      assert json_response(conn, 200) == []
    end
  end
end
