defmodule UniWeb.MonographLive.IndexTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  test "displays the correct monographs", %{conn: conn} do
    user = insert(:user)
    another_user = insert(:user, email: "bob@john.com")
    conn = init_test_session(conn, %{user_id: user.id})

    insert(:monograph, owner: user, name: "The monograph name")
    insert(:monograph, owner: another_user, name: "Another monograph name")

    {:ok, _monograph_live, html} = live(conn, Routes.monograph_index_path(conn, :monographs))

    assert html =~ "The monograph name"
    refute html =~ "Another monograph name"
  end

  test "pagination works as expected", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    Enum.each(1..30, fn i ->
      insert(:monograph, owner: user, name: "Monograph number: #{i}")
    end)

    {:ok, monograph_live, _html} = live(conn, Routes.monograph_index_path(conn, :monographs))

    assert has_element?(monograph_live, "li.disabled", "Previous")
    assert has_element?(monograph_live, "li.active", "1")

    Enum.each(1..10, fn i ->
      assert has_element?(monograph_live, "th", "Monograph number: #{i}")
      refute has_element?(monograph_live, "th", "Monograph number: #{i + 10}")
    end)

    monograph_live |> element("a", "Next") |> render_click()

    assert_patch(
      monograph_live,
      Routes.monograph_index_path(conn, :monographs, page: 2, per_page: "10", query: "")
    )

    assert has_element?(monograph_live, "li.active", "2")

    Enum.each(11..20, fn i ->
      assert has_element?(monograph_live, "th", "Monograph number: #{i}")
      refute has_element?(monograph_live, "th", "Monograph number: #{i + 10}")
    end)

    monograph_live |> element("a", "Next") |> render_click()

    assert_patch(
      monograph_live,
      Routes.monograph_index_path(conn, :monographs, page: 3, per_page: "10", query: "")
    )

    assert has_element?(monograph_live, "li.active", "3")
    assert has_element?(monograph_live, "li.disabled", "Next")

    Enum.each(21..30, fn i ->
      assert has_element?(monograph_live, "th", "Monograph number: #{i}")
      refute has_element?(monograph_live, "th", "Monograph number: #{i + 10}")
    end)
  end

  test "per_page splits the monographs correctly", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    Enum.each(1..50, fn i ->
      insert(:monograph, owner: user, name: "Monograph number: #{i}")
    end)

    {:ok, monograph_live, _html} = live(conn, Routes.monograph_index_path(conn, :monographs))

    Enum.each(1..10, fn i ->
      assert has_element?(monograph_live, "th", "Monograph number: #{i}")
      refute has_element?(monograph_live, "th", "Monograph number: #{i + 10}")
    end)

    html =
      monograph_live
      |> element("form#filters")
      |> render_change(%{"per_page" => "25"})

    assert_patch(
      monograph_live,
      Routes.monograph_index_path(conn, :monographs, page: 1, per_page: "25", query: "")
    )

    Enum.each(1..25, fn i ->
      assert html =~ "Monograph number: #{i}"
    end)

    monograph_live |> element("a", "Next") |> render_click()

    assert_patch(
      monograph_live,
      Routes.monograph_index_path(conn, :monographs, page: 2, per_page: "25", query: "")
    )

    Enum.each(26..50, fn i ->
      assert has_element?(monograph_live, "th", "Monograph number: #{i}")
    end)
  end

  test "search filters monographs by name", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    Enum.each(1..50, fn i ->
      insert(:monograph, owner: user, name: "Monograph number: #{i}")
    end)

    {:ok, monograph_live, _html} = live(conn, Routes.monograph_index_path(conn, :monographs))

    Enum.each(1..10, fn i ->
      assert has_element?(monograph_live, "th", "Monograph number: #{i}")
      refute has_element?(monograph_live, "th", "Monograph number: #{i + 10}")
    end)

    html =
      monograph_live
      |> element("form#filters")
      |> render_change(%{"query" => "1"})

    assert_patch(
      monograph_live,
      Routes.monograph_index_path(conn, :monographs, page: 1, per_page: "10", query: "1")
    )

    assert html =~ "Total of 14 monographs"
    assert html =~ "Monograph number: 1"
    assert html =~ "Monograph number: 10"
    refute html =~ "Monograph number: 21"

    monograph_live |> element("a", "Next") |> render_click()
    html = render(monograph_live)
    assert html =~ "Monograph number: 21"

    html =
      monograph_live
      |> element("form#filters")
      |> render_change(%{"per_page" => "25"})

    assert_patch(
      monograph_live,
      Routes.monograph_index_path(conn, :monographs, page: 1, per_page: "25", query: "1")
    )

    assert html =~ "Monograph number: 21"
  end

  test "uses the page param to show the correct page", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    Enum.each(1..30, fn i ->
      insert(:monograph, owner: user, name: "Monograph number: #{i}")
    end)

    {:ok, monograph_live, _html} =
      live(conn, Routes.monograph_index_path(conn, :monographs, page: 2))

    assert has_element?(monograph_live, "li.active", "2")

    Enum.each(11..20, fn i ->
      assert has_element?(monograph_live, "th", "Monograph number: #{i}")
      refute has_element?(monograph_live, "th", "Monograph number: #{i + 10}")
    end)
  end

  test "Add icon redirects to monographs/new page", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    {:ok, monograph_live, _html} = live(conn, Routes.monograph_index_path(conn, :monographs))

    monograph_live
    |> element("a#new-monograph")
    |> render_click()
    |> follow_redirect(conn, Routes.monograph_new_path(conn, :monographs))
  end

  test "edit icon redirects to the edit page", %{conn: conn} do
    user = insert(:user)
    monograph_1 = insert(:monograph, owner: user, name: "Monograph one")
    _monograph_2 = insert(:monograph, owner: user, name: "Monograph two")

    conn = init_test_session(conn, %{user_id: user.id})

    {:ok, monograph_live, _html} = live(conn, Routes.monograph_index_path(conn, :monographs))

    {:ok, _view, html} =
      monograph_live
      |> element("a#monograph-edit-#{monograph_1.id}")
      |> render_click()
      |> follow_redirect(conn, Routes.monograph_edit_path(conn, :monographs, monograph_1))

    html =~ "Monograph one"
  end
end
