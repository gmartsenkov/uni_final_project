defmodule Uni.UsersTest do
  use Uni.DataCase

  alias Uni.Users

  describe "users" do
    alias Uni.Users.User

    @valid_attrs %{email: "some email", name: "some name", password: "1234"}
    @update_attrs %{email: "some updated email", name: "some updated name", password: "4321"}
    @invalid_attrs %{email: nil, name: nil}

    test "autocomplete/1 returns the users matching the query" do
      _jon = insert(:user, name: "Jon Snow")
      rob = insert(:user, name: "Rob Stark")
      arya = insert(:user, name: "Arya Stark")

      assert Users.autocomplete("stark") == [rob, arya]
    end

    test "list_users/0 returns all users" do
      user = insert(:user)
      assert Users.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)
      assert Users.get_user!(user.id) == user
    end

    test "get_users/1 returns the users with given ids" do
      user = insert(:user)
      user_2 = insert(:user)
      _user_3 = insert(:user)

      assert Users.get_users([user.id, user_2.id]) == [user, user_2]
    end

    test "get_by_email/1 returns the user with given an email" do
      user = insert(:user)
      assert Users.get_by_email(user.email) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Users.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.name == "some name"
      assert user.password == "1234"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = insert(:user)
      assert {:ok, %User{} = user} = Users.update_user(user, @update_attrs)
      assert user.email == "some updated email"
      assert user.name == "some updated name"
      assert user.password == "4321"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.id)
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
