defmodule UniWeb.UserLive.ProfileTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  test "changing tabs works correctly", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})
    {:ok, profile_live, html} = live(conn, Routes.user_profile_path(conn, :my_profile))

    assert has_element?(profile_live, "a.active", "Profile")
    assert html =~ "Email"
    assert html =~ "Name"

    html =
      profile_live
      |> element("a", "Change Email")
      |> render_click()

    assert has_element?(profile_live, "a.active", "Change Email")
    assert html =~ "Email"
    assert html =~ "New Email"
    assert html =~ "Password"

    html =
      profile_live
      |> element("a", "Change Password")
      |> render_click()

    assert has_element?(profile_live, "a.active", "Change Password")
    assert html =~ "Password"
    assert html =~ "New Password"
  end

  test "updating the profile", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})
    {:ok, profile_live, html} = live(conn, Routes.user_profile_path(conn, :my_profile))

    assert has_element?(profile_live, "a.active", "Profile")
    assert html =~ user.email
    assert html =~ user.name

    assert profile_live
           |> element("form#profile")
           |> render_submit(%{"user" => %{"name" => ""}}) =~ "can&apos;t be blank"

    {:ok, _live, html} =
      profile_live
      |> element("form#profile")
      |> render_submit(%{"user" => %{"name" => "Arnold"}})
      |> follow_redirect(conn, Routes.user_profile_path(conn, :my_profile))

    assert html =~ "Profile updated successfully"
    assert html =~ "Arnold"
  end

  test "updating the email", %{conn: conn} do
    insert(:user, email: "rob@stark")
    user = insert(:user, password: Bcrypt.hash_pwd_salt("1234"))
    conn = init_test_session(conn, %{user_id: user.id})
    {:ok, profile_live, _html} = live(conn, Routes.user_profile_path(conn, :my_profile))

    profile_live
    |> element("a", "Change Email")
    |> render_click()

    assert profile_live
           |> form("#email", user: %{"new_email" => "", "password" => "incorrect"})
           |> render_submit() =~ "Password is incorrect"

    assert profile_live
           |> form("#email", user: %{"new_email" => "", "password" => "1234"})
           |> render_submit() =~ "\nEmail can&apos;t be blank"

    assert profile_live
           |> form("#email", user: %{"new_email" => "rob@stark", "password" => "1234"})
           |> render_submit() =~ "Email has already been taken"

    html =
      profile_live
      |> form("#email", user: %{"new_email" => "bob@stark", "password" => "1234"})
      |> render_submit()

    assert html =~ "Email updated successfully"
    refute String.contains?(html, "Email has already been taken")
  end
end
