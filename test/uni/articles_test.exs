defmodule Uni.ArticlesTest do
  use Uni.DataCase

  alias Uni.Articles

  describe "articles" do
    alias Uni.Articles.Article

    @valid_attrs %{
      name: "some name",
      owner_id: 42,
      publisher: "some publisher",
      scopus: true,
      type: "national",
      wofscience: true,
      year: 42
    }
    @update_attrs %{
      name: "some updated name",
      owner_id: 43,
      publisher: "some updated publisher",
      scopus: false,
      type: "international",
      wofscience: false,
      year: 43
    }
    @invalid_attrs %{
      name: nil,
      owner_id: nil,
      publisher: nil,
      scopus: nil,
      type: nil,
      wofscience: nil,
      year: nil
    }

    def article_fixture(attrs \\ %{}) do
      {:ok, article} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Articles.create_article()

      article
    end

    test "list_articles/0 returns all articles" do
      article = article_fixture()
      assert Articles.list_articles() == [article]
    end

    test "get_article!/1 returns the article with given id" do
      article = article_fixture()
      assert Articles.get_article!(article.id) == article
    end

    test "create_article/1 with valid data creates a article" do
      assert {:ok, %Article{} = article} = Articles.create_article(@valid_attrs)
      assert article.name == "some name"
      assert article.owner_id == 42
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
      article = article_fixture()
      assert {:ok, %Article{} = article} = Articles.update_article(article, @update_attrs)
      assert article.name == "some updated name"
      assert article.owner_id == 43
      assert article.publisher == "some updated publisher"
      assert article.scopus == false
      assert article.type == "international"
      assert article.wofscience == false
      assert article.year == 43
    end

    test "update_article/2 with invalid data returns error changeset" do
      article = article_fixture()
      assert {:error, %Ecto.Changeset{}} = Articles.update_article(article, @invalid_attrs)
      assert article == Articles.get_article!(article.id)
    end

    test "delete_article/1 deletes the article" do
      article = article_fixture()
      assert {:ok, %Article{}} = Articles.delete_article(article)
      assert_raise Ecto.NoResultsError, fn -> Articles.get_article!(article.id) end
    end

    test "change_article/1 returns a article changeset" do
      article = article_fixture()
      assert %Ecto.Changeset{} = Articles.change_article(article)
    end
  end
end
