defmodule UniWeb.UserLive.ProfileTest do
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

  test "changing tabs works correctly", %{conn: conn, user: user} do
    conn = init_test_session(conn, %{user_id: user.id})
    {:ok, profile_live, html} = live(conn, Routes.user_profile_path(conn, :my_profile))

    assert has_element?(profile_live, "a.active", "Profile")
    assert html =~ "Email"
    assert html =~ "Name"

    html =
      profile_live
      |> element("a", "Change Password")
      |> render_click()

    assert has_element?(profile_live, "a.active", "Change Password")
    assert html =~ "Password"
    assert html =~ "New Password"
  end

  test "updating the profile", %{
    conn: conn,
    user: user,
    another_faculty: faculty,
    another_department: department
  } do
    conn = init_test_session(conn, %{user_id: user.id})
    {:ok, profile_live, html} = live(conn, Routes.user_profile_path(conn, :my_profile))

    assert has_element?(profile_live, "a.active", "Profile")
    assert html =~ user.email
    assert html =~ user.name

    assert profile_live
           |> element("form#profile")
           |> render_submit(%{"user" => %{"name" => ""}}) =~ "can&apos;t be blank"

    {:ok, live, html} =
      profile_live
      |> element("form#profile")
      |> render_submit(%{
        "user" => %{
          "name" => "Arnold",
          "department_id" => department.id,
          "faculty_id" => faculty.id,
          "admin" => true,
          "head_department" => true,
          "head_faculty" => true,
        }
      })
      |> follow_redirect(conn, Routes.user_profile_path(conn, :my_profile))

    assert html =~ "Profile updated successfully"
    assert html =~ "Arnold"
    assert has_element?(live, "option", "Tech")
    assert has_element?(live, "option", "Web")

    user = Uni.Users.get_user(user.id)

    assert user.faculty.id == faculty.id
    assert user.department.id == department.id
    assert user.admin == false
    assert user.head_department == false
    assert user.head_faculty == false
  end

  describe "updating the password" do
    test "returns the correct error when current password is wrong", %{conn: conn, user: user} do
      conn = init_test_session(conn, %{user_id: user.id})
      {:ok, profile_live, _html} = live(conn, Routes.user_profile_path(conn, :my_profile))

      profile_live
      |> element("a", "Change Password")
      |> render_click()

      profile_live
      |> form("#change_password")
      |> render_submit(%{
        "change_password" => %{"password" => "invalid", "new_password" => "4321"}
      })

      assert has_element?(profile_live, "p", "The password is wrong")
    end

    test "updates the user password", %{conn: conn, user: user} do
      conn = init_test_session(conn, %{user_id: user.id})

      assert Bcrypt.verify_pass("1234", user.password)

      {:ok, profile_live, _html} = live(conn, Routes.user_profile_path(conn, :my_profile))

      profile_live
      |> element("a", "Change Password")
      |> render_click()

      {:ok, _profile_live, html} =
        profile_live
        |> form("#change_password")
        |> render_submit(%{"change_password" => %{"password" => "1234", "new_password" => "4321"}})
        |> follow_redirect(conn, Routes.user_profile_path(conn, :my_profile))

      assert html =~ "Password updated successfully"

      user = Uni.Repo.get_by(User, id: user.id)

      assert Bcrypt.verify_pass("4321", user.password)
    end
  end
end
