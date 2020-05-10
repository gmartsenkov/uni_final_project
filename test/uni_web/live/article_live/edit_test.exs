defmodule UniWeb.ArticleLive.EditTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  @update_params %{
    "name" => "Article update",
    "publisher" => "new publisher",
    "type" => "international",
    "year" => 2005,
    "scopus" => "false",
    "wofscience" => "true"
  }
  @invalid_params %{
    "name" => nil,
    "publisher" => nil,
    "year" => nil
  }

  test "redirects correctly when article is not found", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})
    article = %Uni.Articles.Article{id: 0}

    {:ok, _article_live, html} =
      live(conn, Routes.article_edit_path(conn, :articles, article))
      |> follow_redirect(conn, Routes.article_index_path(conn, :articles))

    assert html =~ "Article not found"
  end

  test "updates the article", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})
    author_1 = insert(:user, name: "Rob Stark")
    author_2 = insert(:user, name: "Arya Stark")
    article = insert(:article, owner: user, authors: [author_1])

    {:ok, article_live, html} = live(conn, Routes.article_edit_path(conn, :articles, article))

    assert html =~ "Edit Article"

    assert has_element?(article_live, "li#author-#{author_1.id}", author_1.name)
    refute has_element?(article_live, "li#author-1", "Rob Stark")

    article_live
    |> element("div#author-multiselect")
    |> render_hook("add_author", %{"id" => 1, "text" => "Rob Stark"})

    assert has_element?(article_live, "li#author-1", "Rob Stark")

    article_live
    |> element("div#author-multiselect")
    |> render_hook("add_author", %{"id" => "#{author_2.id}", "text" => author_2.name})

    assert article_live
           |> element("div#author-multiselect")
           |> render_hook("add_author", %{"id" => "#{author_2.id}", "text" => author_2.name}) =~
             "Author is already in the list"

    assert has_element?(article_live, "li#author-#{author_2.id}", author_2.name)

    article_live
    |> element("a#remove-author-1")
    |> render_click()

    refute has_element?(article_live, "li#author-1", "Rob Stark")

    assert article_live
           |> form("#articles-form", article: @invalid_params)
           |> render_change() =~ "can&apos;t be blank"

    assert Uni.Articles.Author |> Uni.Repo.all() |> length == 1

    {:ok, _, html} =
      article_live
      |> form("#articles-form", article: @update_params)
      |> render_submit()
      |> follow_redirect(conn, Routes.article_edit_path(conn, :articles, article))

    assert Uni.Articles.Author |> Uni.Repo.all() |> length == 2

    assert html =~ "Article updated successfuly"
    assert html =~ "Article updated"
    assert html =~ "2005"
  end
end
