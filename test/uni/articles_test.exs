defmodule Uni.ArticlesTest do
  use Uni.DataCase

  alias Uni.Articles
  alias Uni.Users

  describe "articles" do
    alias Uni.Articles.Article

    @valid_attrs %{
      name: "some name",
      publisher: "some publisher",
      scopus: true,
      type: "national",
      wofscience: true,
      year: 42
    }
    @update_attrs %{
      name: "some updated name",
      publisher: "some updated publisher",
      scopus: false,
      type: "international",
      wofscience: false,
      year: 43
    }
    @invalid_attrs %{
      name: nil,
      owner: nil,
      publisher: nil,
      scopus: nil,
      type: nil,
      wofscience: nil,
      year: nil
    }

    def owner do
      {:ok, user} = Users.create_user(%{name: "jon", email: "jon@snow", password: "1234"})
      user
    end

    def article_fixture(attrs \\ %{}) do
      {:ok, article} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Articles.create_article()

      article
    end

    test "list_articles/0 returns all articles" do
      article = article_fixture(%{owner: owner()})
      assert Articles.list_articles() == [article]
    end

    test "get_article!/1 returns the article with given id" do
      article = article_fixture(%{owner: owner()})
      assert Articles.get_article!(article.id) == article
    end

    test "create_article/1 with valid data creates a article" do
      owner = owner()
      attrs = Map.put(@valid_attrs, :owner, owner)
      assert {:ok, %Article{} = article} = Articles.create_article(attrs)
      assert article.name == "some name"
      assert article.owner == owner
      assert article.publisher == "some publisher"
      assert article.scopus == true
      assert article.type == "national"
      assert article.wofscience == true
      assert article.year == 42
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Articles.create_article(@invalid_attrs)
    end

    test "update_article/2 with valid data updates the article" do
      owner = owner()
      article = article_fixture(%{owner: owner})
      new_owner = owner()
      attrs = Map.put(@update_attrs, :owner, new_owner)
      assert {:ok, %Article{} = article} = Articles.update_article(article, attrs)
      assert article.name == "some updated name"
      assert article.owner == new_owner
      assert article.publisher == "some updated publisher"
      assert article.scopus == false
      assert article.type == "international"
      assert article.wofscience == false
      assert article.year == 43
    end

    test "update_article/2 with invalid data returns error changeset" do
      article = article_fixture(%{owner: owner()})
      assert {:error, %Ecto.Changeset{}} = Articles.update_article(article, @invalid_attrs)
      assert article == Articles.get_article!(article.id)
    end

    test "delete_article/1 deletes the article" do
      article = article_fixture(%{owner: owner()})
      assert {:ok, %Article{}} = Articles.delete_article(article)
      assert_raise Ecto.NoResultsError, fn -> Articles.get_article!(article.id) end
    end

    test "change_article/1 returns a article changeset" do
      article = article_fixture(%{owner: owner()})
      assert %Ecto.Changeset{} = Articles.change_article(article)
    end
  end
end
