defmodule Uni.ArticlesTest do
  use Uni.DataCase

  alias Uni.Articles
  alias Uni.Articles.Article

  describe "articles" do
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
      owner = insert(:user, email: "mark@john.com")
      author = insert(:user, email: "bob@john.com")
      article = insert(:article, owner: owner, authors: [author])
      result = Articles.get_article(article.id)

      assert result == article
      assert result.owner == owner
      assert result.authors == [author]
    end

    test "create_article/1 with valid data creates a article" do
      owner = insert(:user, email: "bob@john.com")
      user_1 = insert(:user, email: "mike@john.com")
      user_2 = insert(:user, email: "mark@john.com")
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
      another_owner = insert(:user, email: "bob@john.com")
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
      owner = insert(:user, email: "bob@john.com")
      another_owner = insert(:user, email: "boby@john.com")
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
      owner = insert(:user, email: "bob@john.com")
      user_1 = insert(:user, email: "mike@john.com")
      user_2 = insert(:user, email: "mark@john.com")
      article = insert(:article, owner: owner, authors: [user_1])

      new_owner = insert(:user, email: "arnold@john.com")

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

  describe "filter faculty" do
    setup do
      faculty = insert(:faculty)
      another_faculty = insert(:faculty)
      department = insert(:department, faculty: faculty)
      another_department = insert(:department, faculty: another_faculty)

      author = insert(:user, email: "jon", name: "Jon", department: department, faculty: faculty)

      another_author =
        insert(:user,
          email: "rob",
          name: "Rob",
          department: another_department,
          faculty: another_faculty
        )

      owner = insert(:user, email: "bob", name: "Bob", department: department, faculty: faculty)

      article = insert(:article, owner: owner, authors: [author])
      article_2 = insert(:article, owner: owner, authors: [another_author])

      [article: article, article_2: article_2, faculty: faculty, another_faculty: another_faculty]
    end

    test "returns correct article", %{article: article, faculty: faculty} do
      results =
        Article
        |> Articles.filter("faculty", faculty.id)
        |> Uni.Repo.all()

      assert Enum.count(results) == 1

      [first] = results

      assert first.id == article.id
    end

    test "that it works with another", %{article_2: article, another_faculty: faculty} do
      results =
        Article
        |> Articles.filter("faculty", faculty.id)
        |> Uni.Repo.all()

      assert Enum.count(results) == 1

      [first] = results

      assert first.id == article.id
    end
  end

  describe "filter department" do
    setup do
      faculty = insert(:faculty)
      another_faculty = insert(:faculty)
      department = insert(:department, faculty: faculty)
      another_department = insert(:department, faculty: another_faculty)

      author = insert(:user, email: "jon", name: "Jon", department: department, faculty: faculty)

      another_author =
        insert(:user,
          email: "rob",
          name: "Rob",
          department: another_department,
          faculty: another_faculty
        )

      owner = insert(:user, email: "bob", name: "Bob", department: department, faculty: faculty)

      article = insert(:article, owner: owner, authors: [author])
      article_2 = insert(:article, owner: owner, authors: [another_author])

      [
        article: article,
        article_2: article_2,
        department: department,
        another_department: another_department
      ]
    end

    test "returns correct article", %{article: article, department: department} do
      results =
        Article
        |> Articles.filter("department", department.id)
        |> Uni.Repo.all()

      assert Enum.count(results) == 1

      [first] = results

      assert first.id == article.id
    end

    test "that it works with another", %{article_2: article, another_department: department} do
      results =
        Article
        |> Articles.filter("department", department.id)
        |> Uni.Repo.all()

      assert Enum.count(results) == 1

      [first] = results

      assert first.id == article.id
    end
  end

  describe "filter scopus" do
    setup do
      [
        article_1: insert(:article, scopus: true),
        article_2: insert(:article, scopus: false),
        article_3: insert(:article, scopus: false)
      ]
    end

    test "true", %{article_1: article} do
      results = Article |> Articles.filter("scopus", "true") |> Uni.Repo.all()

      assert Enum.count(results) == 1

      [first] = results

      assert first.id == article.id
    end

    test "false", %{article_2: article_2, article_3: article_3} do
      results = Article |> Articles.filter("scopus", "false") |> Uni.Repo.all()

      assert Enum.count(results) == 2

      [first, second] = results

      assert first.id == article_2.id
      assert second.id == article_3.id
    end

    test "all" do
      results = Article |> Articles.filter("scopus", "all") |> Uni.Repo.all()

      assert Enum.count(results) == 3
    end
  end

  describe "filter wofscience" do
    setup do
      [
        article_1: insert(:article, wofscience: true),
        article_2: insert(:article, wofscience: false),
        article_3: insert(:article, wofscience: false)
      ]
    end

    test "true", %{article_1: article} do
      results = Article |> Articles.filter("wofscience", "true") |> Uni.Repo.all()

      assert Enum.count(results) == 1

      [first] = results

      assert first.id == article.id
    end

    test "false", %{article_2: article_2, article_3: article_3} do
      results = Article |> Articles.filter("wofscience", "false") |> Uni.Repo.all()

      assert Enum.count(results) == 2

      [first, second] = results

      assert first.id == article_2.id
      assert second.id == article_3.id
    end

    test "all" do
      results = Article |> Articles.filter("wofscience", "all") |> Uni.Repo.all()

      assert Enum.count(results) == 3
    end
  end

  describe "filter start_date" do
    setup do
      [
        article_1: insert(:article, year: 1995),
        article_2: insert(:article, year: 2005),
        article_3: insert(:article, year: 2009)
      ]
    end

    test "2006", %{article_3: article} do
      results = Article |> Articles.filter("start_date", "2006") |> Uni.Repo.all()

      assert Enum.count(results) == 1

      [first] = results

      assert first.id == article.id
    end

    test "2005", %{article_2: article_2, article_3: article_3} do
      results = Article |> Articles.filter("start_date", "2005") |> Uni.Repo.all()

      assert Enum.count(results) == 2

      [first, second] = results

      assert first.id == article_2.id
      assert second.id == article_3.id
    end
  end

  describe "filter end_date" do
    setup do
      [
        article_1: insert(:article, year: 1995),
        article_2: insert(:article, year: 2005),
        article_3: insert(:article, year: 2009)
      ]
    end

    test "2004", %{article_1: article} do
      results = Article |> Articles.filter("end_date", "2004") |> Uni.Repo.all()

      assert Enum.count(results) == 1

      [first] = results

      assert first.id == article.id
    end

    test "2005", %{article_1: article_1, article_2: article_2} do
      results = Article |> Articles.filter("end_date", "2005") |> Uni.Repo.all()

      assert Enum.count(results) == 2

      [first, second] = results

      assert first.id == article_1.id
      assert second.id == article_2.id
    end
  end

  describe "filter type" do
    setup do
      [
        article_1: insert(:article, type: "national"),
        article_2: insert(:article, type: "international"),
        article_3: insert(:article, type: "international")
      ]
    end

    test "true", %{article_1: article} do
      results = Article |> Articles.filter("type", "national") |> Uni.Repo.all()

      assert Enum.count(results) == 1

      [first] = results

      assert first.id == article.id
    end

    test "false", %{article_2: article_2, article_3: article_3} do
      results = Article |> Articles.filter("type", "international") |> Uni.Repo.all()

      assert Enum.count(results) == 2

      [first, second] = results

      assert first.id == article_2.id
      assert second.id == article_3.id
    end

    test "all" do
      results = Article |> Articles.filter("type", "all") |> Uni.Repo.all()

      assert Enum.count(results) == 3
    end
  end
end
