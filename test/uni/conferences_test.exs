defmodule Uni.ConferencesTest do
  use Uni.DataCase

  alias Uni.Conferences

  describe "conferences" do
    alias Uni.Conferences.Conference

    @valid_attrs %{
      name: "some name",
      page_end: 42,
      page_start: 42,
      published: true,
      reported: true,
      type: "some type"
    }
    @update_attrs %{
      name: "some updated name",
      page_end: 43,
      page_start: 43,
      published: false,
      reported: false,
      type: "some updated type"
    }
    @invalid_attrs %{
      name: nil,
      page_end: nil,
      page_start: nil,
      published: nil,
      reported: nil,
      type: nil
    }

    test "list_conferences/0 returns all conferences" do
      conference = insert(:conference)
      assert Conferences.list_conferences() == [conference]
    end

    test "get_conference!/1 returns the conference with given id" do
      conference = insert(:conference, owner: insert(:user))
      assert Conferences.get_conference(conference.id) == conference
    end

    test "paginate_conferences/4 returns the paginated conferences" do
      owner = insert(:user)
      another_owner = insert(:user)
      conference_1 = insert(:conference, owner: owner)
      conference_2 = insert(:conference, owner: owner)
      _conference_3 = insert(:conference, owner: another_owner)

      result = Conferences.paginate_conferences(owner.id, "", _page = 1)

      assert %Scrivener.Page{} = result
      assert result.entries == [conference_1, conference_2]
      assert result.total_entries == 2
      assert result.total_pages == 1
    end

    test "paginate_conferences/4 with query returns the paginated conferences" do
      owner = insert(:user)
      another_owner = insert(:user)
      conference_1 = insert(:conference, owner: owner, name: "Conference one two")
      _conference_2 = insert(:conference, owner: owner, name: "Conference three four")
      _conference_3 = insert(:conference, owner: another_owner)

      result = Conferences.paginate_conferences(owner.id, "one", _page = 1)

      assert %Scrivener.Page{} = result
      assert result.entries == [conference_1]
      assert result.total_entries == 1
      assert result.total_pages == 1
    end

    test "create_conference/1 with valid data creates a conference" do
      owner = insert(:user)
      attrs = Map.put(@valid_attrs, :owner, owner)

      assert {:ok, %Conference{} = conference} = Conferences.create_conference(attrs)
      assert conference.name == "some name"
      assert conference.page_end == 42
      assert conference.page_start == 42
      assert conference.published == true
      assert conference.reported == true
      assert conference.type == "some type"
      assert conference.owner == owner
    end

    test "create_conference/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Conferences.create_conference(@invalid_attrs)
    end

    test "update_conference/2 with valid data updates the conference" do
      owner = insert(:user)
      conference = insert(:conference, owner: owner)
      new_owner = insert(:user)
      attrs = Map.put(@update_attrs, :owner, new_owner)
      assert {:ok, %Conference{} = conference} = Conferences.update_conference(conference, attrs)

      assert conference.name == "some updated name"
      assert conference.page_end == 43
      assert conference.page_start == 43
      assert conference.published == false
      assert conference.reported == false
      assert conference.type == "some updated type"
      assert conference.owner == new_owner
    end

    test "update_conference/2 with invalid data returns error changeset" do
      conference = insert(:conference, owner: insert(:user))

      assert {:error, %Ecto.Changeset{}} =
               Conferences.update_conference(conference, @invalid_attrs)

      assert conference == Conferences.get_conference(conference.id)
    end

    test "delete_conference/1 deletes the conference" do
      conference = insert(:conference)
      assert {:ok, %Conference{}} = Conferences.delete_conference(conference)
      assert Conferences.get_conference(conference.id) == nil
    end

    test "change_conference/1 returns a conference changeset" do
      conference = insert(:conference, owner: insert(:user))
      assert %Ecto.Changeset{} = Conferences.change_conference(conference)
    end
  end
end
