defmodule Uni.UsersTest do
  use Uni.DataCase

  alias Uni.Users

  describe "paginate" do
    setup do
      faculty = insert(:faculty)
      department = insert(:department, name: "Tech", faculty: faculty)

      insert(:user, email: "jon@snow", name: "John Snow", faculty: faculty, department: department)

      insert(:user,
        email: "arya@stark",
        name: "Arya Stark",
        faculty: faculty,
        department: department
      )

      insert(:user,
        email: "rob@stark",
        name: "Rob Stark",
        faculty: faculty,
        department: department
      )

      :ok
    end

    test "query" do
      result = Users.paginate("stark")

      assert %Scrivener.Page{} = result
      assert result.page_number == 1
      assert result.page_size == 10
      assert result.total_entries == 2
      assert result.total_pages == 1

      assert Enum.count(result.entries) == 2

      [one, two] = result.entries

      assert one.name == "Arya Stark"
      assert one.faculty.name == "Informatics"
      assert one.department.name == "Tech"
      assert two.name == "Rob Stark"
      assert two.faculty.name == "Informatics"
      assert two.department.name == "Tech"
    end

    test "query works with another" do
      result = Users.paginate("SnoW")

      assert %Scrivener.Page{} = result
      assert result.page_number == 1
      assert result.page_size == 10
      assert result.total_entries == 1
      assert result.total_pages == 1

      assert Enum.count(result.entries) == 1

      [one] = result.entries
      assert one.name == "John Snow"
    end

    test "paginate" do
      result = Users.paginate("", 1, 2)

      assert %Scrivener.Page{} = result
      assert result.page_number == 1
      assert result.page_size == 2
      assert result.total_entries == 3
      assert result.total_pages == 2

      assert Enum.count(result.entries) == 2
      [one, two] = result.entries

      assert one.name == "John Snow"
      assert two.name == "Arya Stark"

      result = Users.paginate("", 2, 2)

      assert %Scrivener.Page{} = result
      assert result.page_number == 2
      assert result.page_size == 2
      assert result.total_entries == 3
      assert result.total_pages == 2

      assert Enum.count(result.entries) == 1
      [one] = result.entries

      assert one.name == "Rob Stark"
    end
  end

  describe "users" do
    alias Uni.Users.User

    @valid_attrs %{email: "some email", name: "some name", password: "1234"}
    @update_attrs %{email: "some updated email", name: "some updated name", password: "4321"}
    @invalid_attrs %{email: nil, name: nil}

    test "autocomplete/1 returns the users matching the query" do
      _jon = insert(:user, name: "Jon Snow", email: "jon@snow.com")
      rob = insert(:user, name: "Rob Stark", email: "rob@stark.com")
      arya = insert(:user, name: "Arya Stark", email: "arya@stark.com")

      assert Users.autocomplete("stark") == [rob, arya]
    end

    test "list_users/0 returns all users" do
      user = insert(:user)
      assert Users.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = insert(:user, faculty: nil, department: nil)
      assert Users.get_user!(user.id) == user
    end

    test "get_users/1 returns the users with given ids" do
      user = insert(:user, email: "bob@bob.com")
      user_2 = insert(:user, email: "jon@snow.com")
      _user_3 = insert(:user, email: "mike@bob.com")

      assert Users.get_users([user.id, user_2.id]) == [user, user_2]
    end

    test "get_by_email/1 returns the user with given an email" do
      user = insert(:user)
      assert Users.get_by_email(user.email) == user
    end

    test "create_user/1 with valid data creates a user" do
      faculty = insert(:faculty)
      department = insert(:department, faculty: faculty)

      params = Map.merge(@valid_attrs, %{faculty_id: faculty.id, department_id: department.id})

      assert {:ok, %User{} = user} = Users.create_user(params)
      assert user.email == "some email"
      assert user.name == "some name"
      assert user.password == "1234"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      faculty = insert(:faculty)
      department = insert(:department, faculty: faculty)
      user = insert(:user)
      params = Map.merge(@update_attrs, %{faculty_id: faculty.id, department_id: department.id})

      assert {:ok, %User{} = user} = Users.update_user(user, params)
      assert user.email == "some updated email"
      assert user.name == "some updated name"
      assert user.password == "4321"
    end

    test "update_user/2 with invalid data returns error changeset" do
      faculty = insert(:faculty)
      department = insert(:department, faculty: faculty)

      user = insert(:user, faculty: faculty, department: department)
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)

      result = Users.get_user!(user.id)
      assert user.id == result.id
      assert user.name == result.name
      assert user.email == result.email
      assert user.password == result.password
      assert user.faculty == result.faculty
      assert %Uni.Faculties.Department{} = result.department
      assert result.department.id == department.id
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user)
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = insert(:user)
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end
