defmodule Uni.FacultiesTest do
  use Uni.DataCase

  alias Uni.Faculties

  describe "faculties" do
    setup do
      insert(:faculty, name: "Arts")
      insert(:faculty, name: "Physics")
	    :ok
    end

    test "it returns all of the faculties" do
      results = Faculties.faculties()

      assert Enum.count(results) == 2

      [first, second] = results

      assert first.name == "Arts"
      assert second.name == "Physics"
    end
  end

  describe "departments" do
	  setup do
	    faculty_1 = insert(:faculty)
	    faculty_2 = insert(:faculty)

      insert(:department, faculty_id: faculty_1.id, name: "Tech")
      insert(:department, faculty_id: faculty_1.id, name: "Math")
      insert(:department, faculty_id: faculty_2.id, name: "Art")

      [
        faculty_1: faculty_1,
        faculty_2: faculty_2
      ]
    end

    test "it returns correct departments", %{faculty_1: faculty} do
      results = Faculties.departments(faculty)

      assert Enum.count(results) == 2

      [first, second] = results

      assert first.name == "Tech"
      assert second.name == "Math"
    end
  end
end
