defmodule UniWeb.ArticleLive.EditTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  @user_params %{"name" => "Bob", "email" => "bob@jon", "password" => "1234"}
  @article_attrs %{
    name: "some name",
    publisher: "some publisher",
    scopus: true,
    type: "national",
    wofscience: true,
    year: 42
  }
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

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@user_params)
      |> Map.update("password", "1234", &Bcrypt.hash_pwd_salt(&1))
      |> Uni.Users.create_user()

    user
  end

  def article_fixture(attrs \\ %{}) do
    {:ok, article} =
      attrs
      |> Enum.into(@article_attrs)
      |> Uni.Articles.create_article()

    article
  end

  test "redirects correctly when article is not found", %{conn: conn} do
    user = user_fixture()
    conn = init_test_session(conn, %{user_id: user.id})
    article = %Uni.Articles.Article{id: 0}

    {:ok, _article_live, html} =
      live(conn, Routes.article_edit_path(conn, :articles, article))
      |> follow_redirect(conn, Routes.article_index_path(conn, :articles))

    assert html =~ "Article not found"
  end

  test "updates the article", %{conn: conn} do
    user = user_fixture()
    conn = init_test_session(conn, %{user_id: user.id})
    article = article_fixture(owner: user)

    {:ok, article_live, html} = live(conn, Routes.article_edit_path(conn, :articles, article))

    assert html =~ "Edit Article"

    assert article_live
           |> form("#articles-form", article: @invalid_params)
           |> render_change() =~ "can&apos;t be blank"

    {:ok, _, html} =
      article_live
      |> form("#articles-form", article: @update_params)
      |> render_submit()
      |> follow_redirect(conn, Routes.article_index_path(conn, :articles))

    assert html =~ "Article updated successfuly"
    assert html =~ "Article updated"
    assert html =~ "2005"
  end
end
