defmodule UniWeb.ArticleLive.NewTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  @user_params %{"name" => "Bob", "email" => "bob@jon", "password" => "1234"}
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

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@user_params)
      |> Map.update("password", "1234", &Bcrypt.hash_pwd_salt(&1))
      |> Uni.Users.create_user()

    user
  end

  test "saves the new article", %{conn: conn} do
    user = user_fixture()
    conn = init_test_session(conn, %{user_id: user.id})

    {:ok, article_live, html} = live(conn, Routes.article_new_path(conn, :articles))

    assert html =~ "New Article"

    assert article_live
           |> form("#articles-form", article: @invalid_params)
           |> render_change() =~ "can&apos;t be blank"

    {:ok, _, html} =
      article_live
      |> form("#articles-form", article: @valid_params)
      |> render_submit()
      |> follow_redirect(conn, Routes.article_index_path(conn, :articles))

    assert html =~ "Article created successfuly"
    assert html =~ "Article 1"
    assert html =~ "1994"
  end
end
