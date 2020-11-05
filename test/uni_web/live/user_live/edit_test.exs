defmodule UniWeb.UserLive.EditTest do
  use UniWeb.ConnCase

  alias Uni.Users.User

  import Phoenix.LiveViewTest

  setup do
    faculty = insert(:faculty)
    department = insert(:department, faculty: faculty)
    another_faculty = insert(:faculty, name: "Tech")
    another_department = insert(:department, name: "Web", faculty: another_faculty)

    [
      another_department: another_department,
      another_faculty: another_faculty,
      user: insert(:user, faculty: faculty, department: department)
    ]
  end
end
