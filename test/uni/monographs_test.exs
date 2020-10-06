defmodule Uni.MonographsTest do
  use Uni.DataCase

  alias Uni.Monographs

  describe "monographs" do
    alias Uni.Monographs.Monograph

    @valid_attrs %{name: "some name", publisher: "some publisher", year: 42}
    @update_attrs %{name: "some updated name", publisher: "some updated publisher", year: 43}
    @invalid_attrs %{name: nil, publisher: nil, year: nil}

    def monograph_fixture(attrs \\ %{}) do
      {:ok, monograph} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Monographs.create_monograph()

      monograph
    end

    test "list_monographs/0 returns all monographs" do
      monograph = monograph_fixture()
      assert Monographs.list_monographs() == [monograph]
    end

    test "get_monograph!/1 returns the monograph with given id" do
      monograph = monograph_fixture()
      assert Monographs.get_monograph!(monograph.id) == monograph
    end

    test "create_monograph/1 with valid data creates a monograph" do
      assert {:ok, %Monograph{} = monograph} = Monographs.create_monograph(@valid_attrs)
      assert monograph.name == "some name"
      assert monograph.publisher == "some publisher"
      assert monograph.year == 42
    end

    test "create_monograph/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Monographs.create_monograph(@invalid_attrs)
    end

    test "update_monograph/2 with valid data updates the monograph" do
      monograph = monograph_fixture()
      assert {:ok, %Monograph{} = monograph} = Monographs.update_monograph(monograph, @update_attrs)
      assert monograph.name == "some updated name"
      assert monograph.publisher == "some updated publisher"
      assert monograph.year == 43
    end

    test "update_monograph/2 with invalid data returns error changeset" do
      monograph = monograph_fixture()
      assert {:error, %Ecto.Changeset{}} = Monographs.update_monograph(monograph, @invalid_attrs)
      assert monograph == Monographs.get_monograph!(monograph.id)
    end

    test "delete_monograph/1 deletes the monograph" do
      monograph = monograph_fixture()
      assert {:ok, %Monograph{}} = Monographs.delete_monograph(monograph)
      assert_raise Ecto.NoResultsError, fn -> Monographs.get_monograph!(monograph.id) end
    end

    test "change_monograph/1 returns a monograph changeset" do
      monograph = monograph_fixture()
      assert %Ecto.Changeset{} = Monographs.change_monograph(monograph)
    end
  end
end
