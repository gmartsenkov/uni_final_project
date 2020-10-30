defmodule UniWeb.ConferenceLive.IndexTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  test "displays the correct conferences", %{conn: conn} do
    user = insert(:user)
    another_user = insert(:user, email: "bob@john.com")
    conn = init_test_session(conn, %{user_id: user.id})

    insert(:conference, owner: user, name: "The conference name")
    insert(:conference, owner: another_user, name: "Another conference name")

    {:ok, _conference_live, html} = live(conn, Routes.conference_index_path(conn, :conferences))

    assert html =~ "The conference name"
    refute html =~ "Another conference name"
  end

  test "pagination works as expected", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    Enum.each(1..30, fn i ->
      insert(:conference, owner: user, name: "Conference number: #{i}")
    end)

    {:ok, conference_live, html} = live(conn, Routes.conference_index_path(conn, :conferences))

    assert has_element?(conference_live, "li.disabled", "Previous")
    assert has_element?(conference_live, "li.active", "1")

    Enum.each(1..10, fn i ->
      assert html =~ "Conference number: #{i}"
      refute String.contains?("Conference number: #{i + 10}", html)
    end)

    conference_live |> element("a", "Next") |> render_click()

    assert_patch(
      conference_live,
      Routes.conference_index_path(conn, :conferences, page: 2, per_page: "10", query: "")
    )

    assert has_element?(conference_live, "li.active", "2")

    html = render(conference_live)

    Enum.each(11..20, fn i ->
      assert html =~ "Conference number: #{i}"
      refute String.contains?("Conference number: #{i + 10}", html)
    end)

    conference_live |> element("a", "Next") |> render_click()

    assert_patch(
      conference_live,
      Routes.conference_index_path(conn, :conferences, page: 3, per_page: "10", query: "")
    )

    assert has_element?(conference_live, "li.active", "3")
    assert has_element?(conference_live, "li.disabled", "Next")

    html = render(conference_live)

    Enum.each(21..30, fn i ->
      assert html =~ "Conference number: #{i}"
      refute String.contains?("Conference number: #{i - 10}", html)
    end)
  end

  test "per_page splits the conferences correctly", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    Enum.each(1..50, fn i ->
      insert(:conference, owner: user, name: "Conference number: #{i}")
    end)

    {:ok, conference_live, html} = live(conn, Routes.conference_index_path(conn, :conferences))

    Enum.each(1..10, fn i ->
      assert html =~ "Conference number: #{i}"
      refute String.contains?("Conference number: #{i + 10}", html)
    end)

    html =
      conference_live
      |> element("form#filters")
      |> render_change(%{"per_page" => "25"})

    assert_patch(
      conference_live,
      Routes.conference_index_path(conn, :conferences, page: 1, per_page: "25", query: "")
    )

    Enum.each(1..25, fn i ->
      assert html =~ "Conference number: #{i}"
    end)

    conference_live |> element("a", "Next") |> render_click()

    assert_patch(
      conference_live,
      Routes.conference_index_path(conn, :conferences, page: 2, per_page: "25", query: "")
    )

    html = render(conference_live)

    Enum.each(26..50, fn i ->
      assert html =~ "Conference number: #{i}"
    end)
  end

  test "search filters conferences by name", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    Enum.each(1..50, fn i ->
      insert(:conference, owner: user, name: "Conference number: #{i}")
    end)

    {:ok, conference_live, _html} = live(conn, Routes.conference_index_path(conn, :conferences))

    Enum.each(1..10, fn i ->
      assert has_element?(conference_live, "th", "Conference number: #{i}")
      refute has_element?(conference_live, "th", "Conference number: #{i + 10}")
    end)

    html =
      conference_live
      |> element("form#filters")
      |> render_change(%{"query" => "1"})

    assert_patch(
      conference_live,
      Routes.conference_index_path(conn, :conferences, page: 1, per_page: "10", query: "1")
    )

    assert html =~ "Total of 14 conferences"
    assert html =~ "Conference number: 1"
    assert html =~ "Conference number: 10"
    refute html =~ "Conference number: 21"

    conference_live |> element("a", "Next") |> render_click()
    html = render(conference_live)
    assert html =~ "Conference number: 21"

    html =
      conference_live
      |> element("form#filters")
      |> render_change(%{"per_page" => "25"})

    assert_patch(
      conference_live,
      Routes.conference_index_path(conn, :conferences, page: 1, per_page: "25", query: "1")
    )

    assert html =~ "Conference number: 21"
  end

  test "uses the page param to show the correct page", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    Enum.each(1..30, fn i ->
      insert(:conference, owner: user, name: "Conference number: #{i}")
    end)

    {:ok, conference_live, html} =
      live(conn, Routes.conference_index_path(conn, :conferences, page: 2))

    assert has_element?(conference_live, "li.active", "2")

    Enum.each(11..20, fn i ->
      assert html =~ "Conference number: #{i}"
    end)
  end

  test "Add icon redirects to conferences/new page", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    {:ok, conference_live, _html} = live(conn, Routes.conference_index_path(conn, :conferences))

    conference_live
    |> element("a#new-conference")
    |> render_click()
    |> follow_redirect(conn, Routes.conference_new_path(conn, :conferences))
  end

  test "edit icon redirects to the edit page", %{conn: conn} do
    user = insert(:user)
    conference_1 = insert(:conference, owner: user, name: "Conference one")
    _conference_2 = insert(:conference, owner: user, name: "Conference two")

    conn = init_test_session(conn, %{user_id: user.id})

    {:ok, conference_live, _html} = live(conn, Routes.conference_index_path(conn, :conferences))

    {:ok, _view, html} =
      conference_live
      |> element("a#conference-edit-#{conference_1.id}")
      |> render_click()
      |> follow_redirect(conn, Routes.conference_edit_path(conn, :conferences, conference_1))

    html =~ "Conference one"
  end
end
