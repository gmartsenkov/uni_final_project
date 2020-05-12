defmodule UniWeb.ConferenceLive.NewTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  @valid_params %{
    "name" => "Conference 1",
    "page_start" => 1,
    "page_end" => 5,
    "type" => "international",
    "published" => true,
    "reported" => true
  }
  @invalid_params %{
    "name" => nil
  }

  test "saves the new conference", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    {:ok, conference_live, html} = live(conn, Routes.conference_new_path(conn, :conferences))

    assert html =~ "New Conference"

    assert conference_live
           |> form("#conferences-form", conference: @invalid_params)
           |> render_change() =~ "can&apos;t be blank"

    {:ok, _, html} =
      conference_live
      |> form("#conferences-form", conference: @valid_params)
      |> render_submit()
      |> follow_redirect(conn, Routes.conference_index_path(conn, :conferences))

    assert html =~ "Conference created successfuly"
    assert html =~ "Conference 1"
    assert html =~ "International"
  end
end
