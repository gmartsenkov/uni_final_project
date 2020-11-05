defmodule UniWeb.ArticleLive.NewTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  @valid_params %{
    "name" => "Article 1",
    "publisher" => "Helikon",
    "type" => "national",
    "year" => 1994,
    "scopus" => "true",
    "wofscience" => "true"
  }
  @invalid_params %{
    "name" => nil,
    "publisher" => nil,
    "year" => nil
  }

  test "saves the new article", %{conn: conn} do
    user = insert(:user)
    author_1 = insert(:user, name: "Bob John", email: "bob@john.com")
    author_2 = insert(:user, name: "Mike Babo", email: "mike@babo.com")
    conn = init_test_session(conn, %{user_id: user.id})

    {:ok, article_live, html} = live(conn, Routes.article_new_path(conn, :articles))

    assert html =~ "New Article"

    refute has_element?(article_live, "li#author-1", "Rob Stark")

    article_live
    |> element("div#author-multiselect")
    |> render_hook("add_author", %{"id" => 1, "text" => "Rob Stark"})

    article_live
    |> element("div#author-multiselect")
    |> render_hook("add_author", %{"id" => author_1.id, "text" => author_1.name})

    article_live
    |> element("div#author-multiselect")
    |> render_hook("add_author", %{"id" => author_2.id, "text" => author_2.name})

    assert has_element?(article_live, "li#author-1", "Rob Stark")
    assert has_element?(article_live, "li#author-#{author_1.id}", author_1.name)
    assert has_element?(article_live, "li#author-#{author_2.id}", author_2.name)

    article_live
    |> element("a#remove-author-1")
    |> render_click()

    refute has_element?(article_live, "li#author-1", "Rob Stark")
    assert has_element?(article_live, "li#author-#{author_1.id}", author_1.name)
    assert has_element?(article_live, "li#author-#{author_2.id}", author_2.name)

    assert article_live
           |> form("#articles-form", article: @invalid_params)
           |> render_change() =~ "can&apos;t be blank"

    {:ok, _, html} =
      article_live
      |> form("#articles-form", article: @valid_params)
      |> render_submit()
      |> follow_redirect(conn, Routes.article_index_path(conn, :articles))

    assert html =~ "Article created successfully"
    assert html =~ "Article 1"
    assert html =~ "1994"

    assert Uni.Articles.Author |> Uni.Repo.all() |> length == 2
  end
end
