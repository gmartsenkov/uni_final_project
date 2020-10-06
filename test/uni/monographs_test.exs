defmodule Uni.MonographsTest do
  use Uni.DataCase

  alias Uni.Monographs

  describe "monographs" do
    alias Uni.Monographs.Monograph

    @valid_attrs %{name: "some name", publisher: "some publisher", year: 42}
    @update_attrs %{name: "some updated name", publisher: "some updated publisher", year: 43}
    @invalid_attrs %{name: nil, publisher: nil, year: nil}

    test "list_monographs/0 returns all monographs" do
      monograph = insert(:monograph, owner: insert(:user))
      assert Monographs.list_monographs() == [monograph]
    end

    test "create_monograph/1 with valid data creates a monograph" do
      owner = insert(:user, email: "bob@john.com")
      user_1 = insert(:user, email: "mike@john.com")
      user_2 = insert(:user, email: "mark@john.com")
      attrs = Map.put(@valid_attrs, :owner, owner)

      attrs = Map.put(attrs, :authors, [user_1, user_2])

      assert {:ok, %Monograph{} = monograph} = Monographs.create_monograph(attrs)
      assert monograph.name == "some name"
      assert monograph.publisher == "some publisher"
      assert monograph.year == 42
      assert monograph.owner == owner
      assert monograph.authors == [user_1, user_2]
    end

    test "create_monograph/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Monographs.create_monograph(@invalid_attrs)
    end

    test "get_monograph/1 returns the monograph with given id" do
      owner = insert(:user, email: "mark@john.com")
      author = insert(:user, email: "bob@john.com")
      monograph = insert(:monograph, owner: owner, authors: [author])
      result = Monographs.get_monograph(monograph.id)

      assert result == monograph
      assert result.owner == owner
      assert result.authors == [author]
    end

    test "paginate_monographs/4 returns the paginated monographs" do
      owner = insert(:user)
      another_owner = insert(:user, email: "bob@john.com")
      monograph_1 = insert(:monograph, owner: owner)
      monograph_2 = insert(:monograph, owner: owner)
      _monograph_3 = insert(:monograph, owner: another_owner)

      result = Monographs.paginate_monographs(owner.id, "", _page = 1)

      assert %Scrivener.Page{} = result
      assert result.entries == [monograph_1, monograph_2]
      assert result.total_entries == 2
      assert result.total_pages == 1
    end

    test "paginate_monographs/4 with query returns the paginated monographs" do
      owner = insert(:user, email: "bob@john.com")
      another_owner = insert(:user, email: "boby@john.com")
      monograph_1 = insert(:monograph, owner: owner, name: "Monograph one two")
      _monograph_2 = insert(:monograph, owner: owner, name: "Monograph three four")
      _monograph_3 = insert(:monograph, owner: another_owner)

      result = Monographs.paginate_monographs(owner.id, "one", _page = 1)

      assert %Scrivener.Page{} = result
      assert result.entries == [monograph_1]
      assert result.total_entries == 1
      assert result.total_pages == 1
    end

    test "update_monograph/2 with valid data updates the monograph" do
      owner = insert(:user, email: "bob@john.com")
      user_1 = insert(:user, email: "mike@john.com")
      user_2 = insert(:user, email: "mark@john.com")
      monograph = insert(:monograph, owner: owner, authors: [user_1])

      new_owner = insert(:user, email: "arnold@john.com")

      attrs = Map.put(@update_attrs, :owner, new_owner)
      attrs = Map.put(attrs, :authors, [user_1, user_2])

      assert {:ok, %Monograph{} = monograph} = Monographs.update_monograph(monograph, attrs)
      assert monograph.name == "some updated name"
      assert monograph.publisher == "some updated publisher"
      assert monograph.year == 43
      assert monograph.owner == new_owner
      assert monograph.authors == [user_1, user_2]
    end

    test "update_monograph/2 with invalid data returns error changeset" do
      monograph = insert(:monograph, owner: insert(:user), authors: [])
      assert {:error, %Ecto.Changeset{}} = Monographs.update_monograph(monograph, @invalid_attrs)
      assert monograph == Monographs.get_monograph(monograph.id)
    end

    test "delete_monograph/1 deletes the monograph" do
      monograph = insert(:monograph, owner: insert(:user))
      assert {:ok, %Monograph{}} = Monographs.delete_monograph(monograph)
      assert Monographs.get_monograph(monograph.id) == nil
    end

    test "change_monograph/1 returns a monograph changeset" do
      monograph = insert(:monograph, owner: insert(:user))
      assert %Ecto.Changeset{} = Monographs.change_monograph(monograph)
    end
  end
end
