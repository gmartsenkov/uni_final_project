defmodule UniWeb.ArticleLive.IndexTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  test "displays the correct articles", %{conn: conn} do
    user = insert(:user)
    another_user = insert(:user, email: "bob@john.com")
    conn = init_test_session(conn, %{user_id: user.id})

    insert(:article, owner: user, name: "The article name")
    insert(:article, owner: another_user, name: "Another article name")

    {:ok, _article_live, html} = live(conn, Routes.article_index_path(conn, :articles))

    assert html =~ "The article name"
    refute html =~ "Another article name"
  end

  test "pagination works as expected", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    Enum.each(1..30, fn i ->
      insert(:article, owner: user, name: "Article number: #{i}")
    end)

    {:ok, article_live, _html} = live(conn, Routes.article_index_path(conn, :articles))

    assert has_element?(article_live, "li.disabled", "Previous")
    assert has_element?(article_live, "li.active", "1")

    Enum.each(1..10, fn i ->
      assert has_element?(article_live, "th", "Article number: #{i}")
      refute has_element?(article_live, "th", "Article number: #{i + 10}")
    end)

    article_live |> element("a", "Next") |> render_click()

    assert_patch(
      article_live,
      Routes.article_index_path(conn, :articles, page: 2, per_page: "10", query: "")
    )

    assert has_element?(article_live, "li.active", "2")

    Enum.each(11..20, fn i ->
      assert has_element?(article_live, "th", "Article number: #{i}")
      refute has_element?(article_live, "th", "Article number: #{i + 10}")
    end)

    article_live |> element("a", "Next") |> render_click()

    assert_patch(
      article_live,
      Routes.article_index_path(conn, :articles, page: 3, per_page: "10", query: "")
    )

    assert has_element?(article_live, "li.active", "3")
    assert has_element?(article_live, "li.disabled", "Next")

    Enum.each(21..30, fn i ->
      assert has_element?(article_live, "th", "Article number: #{i}")
      refute has_element?(article_live, "th", "Article number: #{i + 10}")
    end)
  end

  test "per_page splits the articles correctly", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    Enum.each(1..50, fn i ->
      insert(:article, owner: user, name: "Article number: #{i}")
    end)

    {:ok, article_live, _html} = live(conn, Routes.article_index_path(conn, :articles))

    Enum.each(1..10, fn i ->
      assert has_element?(article_live, "th", "Article number: #{i}")
      refute has_element?(article_live, "th", "Article number: #{i + 10}")
    end)

    article_live
    |> element("form#filters")
    |> render_change(%{"per_page" => "25"})

    assert_patch(
      article_live,
      Routes.article_index_path(conn, :articles, page: 1, per_page: "25", query: "")
    )

    Enum.each(1..25, fn i ->
      assert has_element?(article_live, "th", "Article number: #{i}")
    end)

    article_live |> element("a", "Next") |> render_click()

    assert_patch(
      article_live,
      Routes.article_index_path(conn, :articles, page: 2, per_page: "25", query: "")
    )

    html = render(article_live)

    Enum.each(26..50, fn i ->
      assert html =~ "Article number: #{i}"
    end)
  end

  test "search filters articles by name", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    Enum.each(1..50, fn i ->
      insert(:article, owner: user, name: "Article number: #{i}")
    end)

    {:ok, article_live, html} = live(conn, Routes.article_index_path(conn, :articles))

    Enum.each(1..10, fn i ->
      assert html =~ "Article number: #{i}"
      refute String.contains?("Article number: #{i + 10}", html)
    end)

    html =
      article_live
      |> element("form#filters")
      |> render_change(%{"query" => "1"})

    assert_patch(
      article_live,
      Routes.article_index_path(conn, :articles, page: 1, per_page: "10", query: "1")
    )

    assert html =~ "Total of 14 articles"
    assert html =~ "Article number: 1"
    assert html =~ "Article number: 10"
    refute html =~ "Article number: 21"

    article_live |> element("a", "Next") |> render_click()
    html = render(article_live)
    assert html =~ "Article number: 21"

    html =
      article_live
      |> element("form#filters")
      |> render_change(%{"per_page" => "25"})

    assert_patch(
      article_live,
      Routes.article_index_path(conn, :articles, page: 1, per_page: "25", query: "1")
    )

    assert html =~ "Article number: 21"
  end

  test "uses the page param to show the correct page", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    Enum.each(1..30, fn i ->
      insert(:article, owner: user, name: "Article number: #{i}")
    end)

    {:ok, article_live, _html} = live(conn, Routes.article_index_path(conn, :articles, page: 2))

    assert has_element?(article_live, "li.active", "2")

    Enum.each(11..20, fn i ->
      assert has_element?(article_live, "th", "Article number: #{i}")
    end)
  end

  test "Add icon redirects to articles/new page", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    {:ok, article_live, _html} = live(conn, Routes.article_index_path(conn, :articles))

    article_live
    |> element("a#new-article")
    |> render_click()
    |> follow_redirect(conn, Routes.article_new_path(conn, :articles))
  end

  test "edit icon redirects to the edit page", %{conn: conn} do
    user = insert(:user)
    article_1 = insert(:article, owner: user, name: "Article one")
    _article_2 = insert(:article, owner: user, name: "Article two")

    conn = init_test_session(conn, %{user_id: user.id})

    {:ok, article_live, _html} = live(conn, Routes.article_index_path(conn, :articles))

    {:ok, _view, html} =
      article_live
      |> element("a#article-edit-#{article_1.id}")
      |> render_click()
      |> follow_redirect(conn, Routes.article_edit_path(conn, :articles, article_1))

    html =~ "Article one"
  end
end
