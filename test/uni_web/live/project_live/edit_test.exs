defmodule UniWeb.ProjectLive.EditTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  @update_params %{
    "name" => "Project 2",
    "project_id" => "#002",
    "project_type" => "international",
    "financing_type" => "external",
    "participation_role" => "Boss"
  }
  @invalid_params %{
    "name" => nil
  }

  test "redirects correctly when project is not found", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})
    project = %Uni.Projects.Project{id: 0}

    {:ok, _project_live, html} =
      live(conn, Routes.project_edit_path(conn, :projects, project))
      |> follow_redirect(conn, Routes.project_index_path(conn, :projects))

    assert html =~ "Project not found"
  end

  test "updates the project", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})
    project = insert(:project, owner: user)

    {:ok, project_live, html} = live(conn, Routes.project_edit_path(conn, :projects, project))

    assert html =~ "Edit Project"

    assert project_live
           |> form("#projects-form", project: @invalid_params)
           |> render_change() =~ "can&apos;t be blank"

    {:ok, _, html} =
      project_live
      |> form("#projects-form", project: @update_params)
      |> render_submit()
      |> follow_redirect(conn, Routes.project_edit_path(conn, :projects, project))

    assert html =~ "Project updated successfuly"
    assert html =~ "Project 2"
    assert html =~ "#002"
  end
end
