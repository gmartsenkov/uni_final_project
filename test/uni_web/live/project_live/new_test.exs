defmodule UniWeb.ProjectLive.NewTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  @valid_params %{
    "name" => "Project 1",
    "project_id" => "#001",
    "project_type" => "national",
    "financing_type" => "internal",
    "participation_role" => "Boss"
  }
  @invalid_params %{
    "name" => nil
  }

  test "saves the new project", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    {:ok, project_live, html} = live(conn, Routes.project_new_path(conn, :projects))

    assert html =~ "New Project"

    assert project_live
           |> form("#projects-form", project: @invalid_params)
           |> render_change() =~ "can&apos;t be blank"

    {:ok, _, html} =
      project_live
      |> form("#projects-form", project: @valid_params)
      |> render_submit()
      |> follow_redirect(conn, Routes.project_index_path(conn, :projects))

    assert html =~ "Project created successfuly"
    assert html =~ "Project 1"
    assert html =~ "#001"
  end
end
