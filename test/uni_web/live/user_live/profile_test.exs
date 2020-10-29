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
end
