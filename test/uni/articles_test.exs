defmodule Uni.ArticlesTest do
  use Uni.DataCase

  alias Uni.Articles

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

    test "list_articles/0 returns all articles" do
      article = insert(:article, owner: insert(:user))
      assert Articles.list_articles() == [article]
    end

    test "get_article/1 returns the article with given id" do
      owner = insert(:user)
      author = insert(:user)
      article = insert(:article, owner: owner, authors: [author])
      result = Articles.get_article(article.id)

      assert result == article
      assert result.owner == owner
      assert result.authors == [author]
    end

    test "create_article/1 with valid data creates a article" do
      owner = insert(:user)
      user_1 = insert(:user)
      user_2 = insert(:user)
      attrs = Map.put(@valid_attrs, :owner, owner)

      attrs = Map.put(attrs, :authors, [user_1, user_2])

      assert {:ok, %Article{} = article} = Articles.create_article(attrs)
      assert article.name == "some name"
      assert article.owner == owner
      assert article.authors == [user_1, user_2]
      assert article.publisher == "some publisher"
      assert article.scopus == true
      assert article.type == "national"
      assert article.wofscience == true
      assert article.year == 42
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Articles.create_article(@invalid_attrs)
    end

    test "paginate_articles/4 returns the paginated articles" do
      owner = insert(:user)
      another_owner = insert(:user)
      article_1 = insert(:article, owner: owner)
      article_2 = insert(:article, owner: owner)
      _article_3 = insert(:article, owner: another_owner)

      result = Articles.paginate_articles(owner.id, "", _page = 1)

      assert %Scrivener.Page{} = result
      assert result.entries == [article_1, article_2]
      assert result.total_entries == 2
      assert result.total_pages == 1
    end

    test "paginate_articles/4 with query returns the paginated articles" do
      owner = insert(:user)
      another_owner = insert(:user)
      article_1 = insert(:article, owner: owner, name: "Article one two")
      _article_2 = insert(:article, owner: owner, name: "Article three four")
      _article_3 = insert(:article, owner: another_owner)

      result = Articles.paginate_articles(owner.id, "one", _page = 1)

      assert %Scrivener.Page{} = result
      assert result.entries == [article_1]
      assert result.total_entries == 1
      assert result.total_pages == 1
    end

    test "update_article/2 with valid data updates the article" do
      owner = insert(:user)
      user_1 = insert(:user)
      user_2 = insert(:user)
      article = insert(:article, owner: owner, authors: [user_1])

      new_owner = insert(:user)

      attrs = Map.put(@update_attrs, :owner, new_owner)
      attrs = Map.put(attrs, :authors, [user_1, user_2])

      assert {:ok, %Article{} = article} = Articles.update_article(article, attrs)
      assert article.name == "some updated name"
      assert article.owner == new_owner
      assert article.authors == [user_1, user_2]
      assert article.publisher == "some updated publisher"
      assert article.scopus == false
      assert article.type == "international"
      assert article.wofscience == false
      assert article.year == 43
    end

    test "update_article/2 with invalid data returns error changeset" do
      article = insert(:article, owner: insert(:user), authors: [])
      assert {:error, %Ecto.Changeset{}} = Articles.update_article(article, @invalid_attrs)
      assert article == Articles.get_article(article.id)
    end

    test "delete_article/1 deletes the article" do
      article = insert(:article, owner: insert(:user))
      assert {:ok, %Article{}} = Articles.delete_article(article)
      assert Articles.get_article(article.id) == nil
    end

    test "change_article/1 returns a article changeset" do
      article = insert(:article, owner: insert(:user))
      assert %Ecto.Changeset{} = Articles.change_article(article)
    end
  end
end
