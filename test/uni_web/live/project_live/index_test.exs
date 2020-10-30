defmodule UniWeb.ProjectLive.IndexTest do
  use UniWeb.ConnCase

  import Phoenix.LiveViewTest

  test "displays the correct projects", %{conn: conn} do
    user = insert(:user)
    another_user = insert(:user, email: "bob@john.com")
    conn = init_test_session(conn, %{user_id: user.id})

    insert(:project, owner: user, name: "The project name")
    insert(:project, owner: another_user, name: "Another project name")

    {:ok, _project_live, html} = live(conn, Routes.project_index_path(conn, :projects))

    assert html =~ "The project name"
    refute html =~ "Another project name"
  end

  test "pagination works as expected", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    Enum.each(1..30, fn i ->
      insert(:project, owner: user, name: "Project number: #{i}")
    end)

    {:ok, project_live, _html} = live(conn, Routes.project_index_path(conn, :projects))

    assert has_element?(project_live, "li.disabled", "Previous")
    assert has_element?(project_live, "li.active", "1")

    Enum.each(1..10, fn i ->
      assert has_element?(project_live, "th", "Project number: #{i}")
      refute has_element?(project_live, "th", "Project number: #{i + 10}")
    end)

    project_live |> element("a", "Next") |> render_click()

    assert_patch(
      project_live,
      Routes.project_index_path(conn, :projects, page: 2, per_page: "10", query: "")
    )

    assert has_element?(project_live, "li.active", "2")

    Enum.each(11..20, fn i ->
      assert has_element?(project_live, "th", "Project number: #{i}")
      refute has_element?(project_live, "th", "Project number: #{i + 10}")
    end)

    project_live |> element("a", "Next") |> render_click()

    assert_patch(
      project_live,
      Routes.project_index_path(conn, :projects, page: 3, per_page: "10", query: "")
    )

    assert has_element?(project_live, "li.active", "3")
    assert has_element?(project_live, "li.disabled", "Next")

    Enum.each(21..30, fn i ->
      assert has_element?(project_live, "th", "Project number: #{i}")
      refute has_element?(project_live, "th", "Project number: #{i + 10}")
    end)
  end

  test "per_page splits the projects correctly", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    Enum.each(1..50, fn i ->
      insert(:project, owner: user, name: "Project number: #{i}")
    end)

    {:ok, project_live, _html} = live(conn, Routes.project_index_path(conn, :projects))

    Enum.each(1..10, fn i ->
      assert has_element?(project_live, "th", "Project number: #{i}")
      refute has_element?(project_live, "th", "Project number: #{i + 10}")
    end)

    project_live
    |> element("form#filters")
    |> render_change(%{"per_page" => "25"})

    assert_patch(
      project_live,
      Routes.project_index_path(conn, :projects, page: 1, per_page: "25", query: "")
    )

    Enum.each(1..25, fn i ->
      assert has_element?(project_live, "th", "Project number: #{i}")
    end)

    project_live |> element("a", "Next") |> render_click()

    assert_patch(
      project_live,
      Routes.project_index_path(conn, :projects, page: 2, per_page: "25", query: "")
    )

    html = render(project_live)

    Enum.each(26..50, fn i ->
      assert html =~ "Project number: #{i}"
    end)
  end

  test "search filters projects by name", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    Enum.each(1..50, fn i ->
      insert(:project, owner: user, name: "Project number: #{i}")
    end)

    {:ok, project_live, html} = live(conn, Routes.project_index_path(conn, :projects))

    Enum.each(1..10, fn i ->
      assert html =~ "Project number: #{i}"
      refute String.contains?("Project number: #{i + 10}", html)
    end)

    html =
      project_live
      |> element("form#filters")
      |> render_change(%{"query" => "1"})

    assert_patch(
      project_live,
      Routes.project_index_path(conn, :projects, page: 1, per_page: "10", query: "1")
    )

    assert html =~ "Total of 14 projects"
    assert html =~ "Project number: 1"
    assert html =~ "Project number: 10"
    refute html =~ "Project number: 21"

    project_live |> element("a", "Next") |> render_click()
    html = render(project_live)
    assert html =~ "Project number: 21"

    html =
      project_live
      |> element("form#filters")
      |> render_change(%{"per_page" => "25"})

    assert_patch(
      project_live,
      Routes.project_index_path(conn, :projects, page: 1, per_page: "25", query: "1")
    )

    assert html =~ "Project number: 21"
  end

  test "uses the page param to show the correct page", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    Enum.each(1..30, fn i ->
      insert(:project, owner: user, name: "Project number: #{i}")
    end)

    {:ok, project_live, html} = live(conn, Routes.project_index_path(conn, :projects, page: 2))

    assert has_element?(project_live, "li.active", "2")

    Enum.each(11..20, fn i ->
      assert html =~ "Project number: #{i}"
    end)
  end

  test "Add icon redirects to projects/new page", %{conn: conn} do
    user = insert(:user)
    conn = init_test_session(conn, %{user_id: user.id})

    {:ok, project_live, _html} = live(conn, Routes.project_index_path(conn, :projects))

    project_live
    |> element("a#new-project")
    |> render_click()
    |> follow_redirect(conn, Routes.project_new_path(conn, :projects))
  end

  test "edit icon redirects to the edit page", %{conn: conn} do
    user = insert(:user)
    project_1 = insert(:project, owner: user, name: "Project one")
    _project_2 = insert(:project, owner: user, name: "Project two")

    conn = init_test_session(conn, %{user_id: user.id})

    {:ok, project_live, _html} = live(conn, Routes.project_index_path(conn, :projects))

    {:ok, _view, html} =
      project_live
      |> element("a#project-edit-#{project_1.id}")
      |> render_click()
      |> follow_redirect(conn, Routes.project_edit_path(conn, :projects, project_1))

    html =~ "Project one"
  end
end
