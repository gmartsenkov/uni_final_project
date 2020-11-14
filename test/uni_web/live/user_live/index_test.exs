defmodule UniWeb.UserLive.IndexTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  setup do
    faculty = insert(:faculty)
    department = insert(:department, faculty: faculty)

    Enum.each(1..30, fn i ->
      insert(:user,
        name: "User #{i}",
        email: "user#{i}@test",
        department: department,
        faculty: faculty
      )
    end)

    [user: insert(:user, admin: true, name: "Jon Snow", faculty: faculty, department: department)]
  end

  test "renders the users", %{conn: conn, user: user} do
    conn = init_test_session(conn, %{user_id: user.id})
    {:ok, live, _html} = live(conn, Routes.user_index_path(conn, :users))

    Enum.each(1..10, fn i ->
      assert has_element?(live, "th", "User #{i}")
      refute has_element?(live, "th", "User #{i + 10}")
    end)

    assert has_element?(live, "th", "Informatics")
    assert has_element?(live, "th", "Math")
    assert has_element?(live, "caption", "Total of 31 users")
  end

  test "can search by name", %{conn: conn, user: user} do
    conn = init_test_session(conn, %{user_id: user.id})
    {:ok, live, _html} = live(conn, Routes.user_index_path(conn, :users))

    live
    |> form("#filters")
    |> render_change(%{ "filters" => %{"query" => "user 15"}})

    assert_patch(
      live,
      Routes.user_index_path(conn, :users,
        admin: "false",
        head_department: "false",
        head_faculty: "false",
        per_page: "10",
        query: "user 15"
      )
    )
    assert has_element?(live, "th", "User 15")
    assert has_element?(live, "caption", "Total of 1 user")
  end

  test "changes the per_page entries", %{conn: conn, user: user} do
    conn = init_test_session(conn, %{user_id: user.id})
    {:ok, live, _html} = live(conn, Routes.user_index_path(conn, :users))

    live
    |> form("#filters")
    |> render_change(%{"filters" => %{"per_page" => "25"}})

    assert_patch(
      live,
      Routes.user_index_path(conn, :users,
        admin: "false",
        head_department: "false",
        head_faculty: "false",
        per_page: "25",
        query: ""
      )
    )

    Enum.each(1..25, fn i ->
      assert has_element?(live, "th", "User #{i}")
    end)
  end

  test "pagination", %{conn: conn, user: user} do
    conn = init_test_session(conn, %{user_id: user.id})
    {:ok, live, _html} = live(conn, Routes.user_index_path(conn, :users))

    Enum.each(1..10, fn i ->
      assert has_element?(live, "th", "User #{i}")
      refute has_element?(live, "th", "User #{i + 10}")
    end)

    live |> element("a", "Next") |> render_click()
    assert_patch(live, Routes.user_index_path(conn, :users, page: "2", per_page: "10", query: ""))

    Enum.each(11..20, fn i ->
      assert has_element?(live, "th", "User #{i}")
    end)
  end

  test "edit icon redirects to the edit page", %{conn: conn, user: user} do
    conn = init_test_session(conn, %{user_id: user.id})

    {:ok, user_live, _html} = live(conn, Routes.user_index_path(conn, :users, per_page: "50"))

    {:ok, _view, html} =
      user_live
      |> element("a#user-edit-#{user.id}")
      |> render_click()
      |> follow_redirect(conn, Routes.user_edit_path(conn, :users, user))

    html =~ "Jon Snow"
  end
end
