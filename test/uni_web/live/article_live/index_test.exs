defmodule UniWeb.ArticleLive.IndexTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  test "displays the correct articles", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    insert(:article, owner: user, name: "The article name")

    {:ok, _article_live, html} = live(conn, Routes.article_index_path(conn, :articles))

    assert html =~ "The article name"
  end

  test "pagination works as expected", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    Enum.each(1..30, fn i ->
      insert(:article, owner: user, name: "Article number: #{i}")
    end)

    {:ok, article_live, html} = live(conn, Routes.article_index_path(conn, :articles))

    assert has_element?(article_live, "li.disabled", "Previous")
    assert has_element?(article_live, "li.active", "1")

    Enum.each(1..10, fn i ->
      assert html =~ "Article number: #{i}"
      refute String.contains?("Article number: #{i + 10}", html)
    end)

    article_live |> element("a", "Next") |> render_click()
    assert has_element?(article_live, "li.active", "2")

    html = render(article_live)

    Enum.each(11..20, fn i ->
      assert html =~ "Article number: #{i}"
      refute String.contains?("Article number: #{i + 10}", html)
    end)

    article_live |> element("a", "Next") |> render_click()
    assert has_element?(article_live, "li.active", "3")
    assert has_element?(article_live, "li.disabled", "Next")

    html = render(article_live)

    Enum.each(21..30, fn i ->
      assert html =~ "Article number: #{i}"
      refute String.contains?("Article number: #{i - 10}", html)
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
