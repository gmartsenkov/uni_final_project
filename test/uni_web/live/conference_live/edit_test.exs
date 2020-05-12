defmodule UniWeb.ConferenceLive.EditTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  @update_params %{
    "name" => "Conference 2",
    "page_start" => 1,
    "page_end" => 5,
    "type" => "international",
    "published" => true,
    "reported" => true
  }
  @invalid_params %{
    "name" => nil
  }

  test "redirects correctly when conference is not found", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})
    conference = %Uni.Conferences.Conference{id: 0}

    {:ok, _conference_live, html} =
      live(conn, Routes.conference_edit_path(conn, :conferences, conference))
      |> follow_redirect(conn, Routes.conference_index_path(conn, :conferences))

    assert html =~ "Conference not found"
  end

  test "updates the conference", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})
    conference = insert(:conference, owner: user)

    {:ok, conference_live, html} =
      live(conn, Routes.conference_edit_path(conn, :conferences, conference))

    assert html =~ "Edit Conference"

    assert conference_live
           |> form("#conferences-form", conference: @invalid_params)
           |> render_change() =~ "can&apos;t be blank"

    {:ok, _, html} =
      conference_live
      |> form("#conferences-form", conference: @update_params)
      |> render_submit()
      |> follow_redirect(conn, Routes.conference_edit_path(conn, :conferences, conference))

    assert html =~ "Conference updated successfuly"
    assert html =~ "Conference 2"
    assert html =~ "International"
  end
end
