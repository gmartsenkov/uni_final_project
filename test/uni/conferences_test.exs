defmodule Uni.ConferencesTest do
  use Uni.DataCase

  alias Uni.Conferences
  alias Uni.Conferences.Conference

  describe "conferences" do
    @valid_attrs %{
      name: "some name",
      page_end: 42,
      page_start: 42,
      published: true,
      reported: true,
      type: "national"
    }
    @update_attrs %{
      name: "some updated name",
      page_end: 43,
      page_start: 43,
      published: false,
      reported: false,
      type: "international"
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
      owner = insert(:user, email: "bob@john.com")
      another_owner = insert(:user, email: "mike@john.com")
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
      another_owner = insert(:user, email: "bob@john.com")
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
      assert conference.type == "national"
      assert conference.owner == owner
    end

    test "create_conference/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Conferences.create_conference(@invalid_attrs)
    end

    test "update_conference/2 with valid data updates the conference" do
      owner = insert(:user)
      conference = insert(:conference, owner: owner)
      new_owner = insert(:user, email: "bob@john.com")
      attrs = Map.put(@update_attrs, :owner, new_owner)
      assert {:ok, %Conference{} = conference} = Conferences.update_conference(conference, attrs)

      assert conference.name == "some updated name"
      assert conference.page_end == 43
      assert conference.page_start == 43
      assert conference.published == false
      assert conference.reported == false
      assert conference.type == "international"
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

  describe "filter published" do
    setup do
      [
        conference_1: insert(:conference, published: true),
        conference_2: insert(:conference, published: false),
        conference_3: insert(:conference, published: false)
      ]
    end

    test "true", %{conference_1: conference} do
      results = Conference |> Conferences.filter("published", "true") |> Uni.Repo.all()

      assert Enum.count(results) == 1

      [first] = results

      assert first.id == conference.id
    end

    test "false", %{conference_2: conference_2, conference_3: conference_3} do
      results = Conference |> Conferences.filter("published", "false") |> Uni.Repo.all()

      assert Enum.count(results) == 2

      [first, second] = results

      assert first.id == conference_2.id
      assert second.id == conference_3.id
    end

    test "all" do
      results = Conference |> Conferences.filter("published", "all") |> Uni.Repo.all()

      assert Enum.count(results) == 3
    end
  end

  describe "filter reported" do
    setup do
      [
        conference_1: insert(:conference, reported: true),
        conference_2: insert(:conference, reported: false),
        conference_3: insert(:conference, reported: false)
      ]
    end

    test "true", %{conference_1: conference} do
      results = Conference |> Conferences.filter("reported", "true") |> Uni.Repo.all()

      assert Enum.count(results) == 1

      [first] = results

      assert first.id == conference.id
    end

    test "false", %{conference_2: conference_2, conference_3: conference_3} do
      results = Conference |> Conferences.filter("reported", "false") |> Uni.Repo.all()

      assert Enum.count(results) == 2

      [first, second] = results

      assert first.id == conference_2.id
      assert second.id == conference_3.id
    end

    test "all" do
      results = Conference |> Conferences.filter("reported", "all") |> Uni.Repo.all()

      assert Enum.count(results) == 3
    end
  end

  describe "filter type" do
    setup do
      [
        conference_1: insert(:conference, type: "national"),
        conference_2: insert(:conference, type: "international"),
        conference_3: insert(:conference, type: "international")
      ]
    end

    test "true", %{conference_1: conference} do
      results = Conference |> Conferences.filter("type", "national") |> Uni.Repo.all()

      assert Enum.count(results) == 1

      [first] = results

      assert first.id == conference.id
    end

    test "false", %{conference_2: conference_2, conference_3: conference_3} do
      results = Conference |> Conferences.filter("type", "international") |> Uni.Repo.all()

      assert Enum.count(results) == 2

      [first, second] = results

      assert first.id == conference_2.id
      assert second.id == conference_3.id
    end

    test "all" do
      results = Conference |> Conferences.filter("type", "all") |> Uni.Repo.all()

      assert Enum.count(results) == 3
    end
  end

  describe "filter faculty" do
    setup do
      faculty = insert(:faculty)
      another_faculty = insert(:faculty)
      department = insert(:department, faculty: faculty)
      another_department = insert(:department, faculty: another_faculty)

      owner = insert(:user, email: "jon", name: "Jon", department: department, faculty: faculty)

      another_owner =
        insert(:user,
          email: "rob",
          name: "Rob",
          department: another_department,
          faculty: another_faculty
        )

      conference = insert(:conference, owner: owner)
      conference_2 = insert(:conference, owner: another_owner)

      [
        conference: conference,
        conference_2: conference_2,
        faculty: faculty,
        another_faculty: another_faculty
      ]
    end

    test "returns correct conference", %{conference: conference, faculty: faculty} do
      results =
        Conference
        |> Conferences.filter("faculty", faculty.id)
        |> Uni.Repo.all()

      assert Enum.count(results) == 1

      [first] = results

      assert first.id == conference.id
    end

    test "that it works with another", %{conference_2: conference, another_faculty: faculty} do
      results =
        Conference
        |> Conferences.filter("faculty", faculty.id)
        |> Uni.Repo.all()

      assert Enum.count(results) == 1

      [first] = results

      assert first.id == conference.id
    end
  end

  describe "filter department" do
    setup do
      faculty = insert(:faculty)
      another_faculty = insert(:faculty)
      department = insert(:department, faculty: faculty)
      another_department = insert(:department, faculty: another_faculty)

      owner = insert(:user, email: "jon", name: "Jon", department: department, faculty: faculty)

      another_owner =
        insert(:user,
          email: "rob",
          name: "Rob",
          department: another_department,
          faculty: another_faculty
        )

      conference = insert(:conference, owner: owner)
      conference_2 = insert(:conference, owner: another_owner)

      [
        conference: conference,
        conference_2: conference_2,
        department: department,
        another_department: another_department
      ]
    end

    test "returns correct conference", %{conference: conference, department: department} do
      results =
        Conference
        |> Conferences.filter("department", department.id)
        |> Uni.Repo.all()

      assert Enum.count(results) == 1

      [first] = results

      assert first.id == conference.id
    end

    test "that it works with another", %{conference_2: conference, another_department: department} do
      results =
        Conference
        |> Conferences.filter("department", department.id)
        |> Uni.Repo.all()

      assert Enum.count(results) == 1

      [first] = results

      assert first.id == conference.id
    end
  end
end
