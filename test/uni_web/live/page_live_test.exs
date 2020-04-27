defmodule UniWeb.PageLiveTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    conn = init_test_session(conn, %{user_id: 1})
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Welcome to Phoenix!"
    assert render(page_live) =~ "Welcome to Phoenix!"
  end
end
