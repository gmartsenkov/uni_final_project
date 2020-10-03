defmodule Uni.ProjectsTest do
  use Uni.DataCase

  alias Uni.Projects

  describe "projects" do
    alias Uni.Projects.Project

    @valid_attrs %{
      financing_type: "external",
      name: "some name",
      participation_role: "some participation_role",
      project_id: "some project_id",
      project_type: "national"
    }
    @update_attrs %{
      financing_type: "internal",
      name: "some updated name",
      participation_role: "some updated participation_role",
      project_id: "some updated project_id",
      project_type: "international"
    }
    @invalid_attrs %{
      financing_type: nil,
      name: nil,
      participation_role: nil,
      project_id: nil,
      project_type: nil
    }

    test "list_projects/0 returns all projects" do
      project = insert(:project)
      assert Projects.list_projects() == [project]
    end

    test "get_project/1 returns the project with given id" do
      project = insert(:project, owner: insert(:user))
      assert Projects.get_project(project.id) == project
    end

    test "paginate_projects/4 returns the paginated projects" do
      owner = insert(:user, email: "bob@john.com")
      another_owner = insert(:user, email: "mike@john.com")
      project_1 = insert(:project, owner: owner)
      project_2 = insert(:project, owner: owner)
      _project_3 = insert(:project, owner: another_owner)

      result = Projects.paginate_projects(owner.id, "", _page = 1)

      assert %Scrivener.Page{} = result
      assert result.entries == [project_1, project_2]
      assert result.total_entries == 2
      assert result.total_pages == 1
    end

    test "paginate_projects/4 with query returns the paginated projects" do
      owner = insert(:user, email: "bob@john.com")
      another_owner = insert(:user, email: "mike@john.com")
      project_1 = insert(:project, owner: owner, name: "Project one two")
      _project_2 = insert(:project, owner: owner, name: "Project three four")
      _project_3 = insert(:project, owner: another_owner)

      result = Projects.paginate_projects(owner.id, "one", _page = 1)

      assert %Scrivener.Page{} = result
      assert result.entries == [project_1]
      assert result.total_entries == 1
      assert result.total_pages == 1
    end

    test "create_project/1 with valid data creates a project" do
      owner = insert(:user)
      attrs = Map.put(@valid_attrs, :owner, owner)
      assert {:ok, %Project{} = project} = Projects.create_project(attrs)
      assert project.financing_type == "external"
      assert project.name == "some name"
      assert project.participation_role == "some participation_role"
      assert project.project_id == "some project_id"
      assert project.project_type == "national"
      assert project.owner == owner
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      owner = insert(:user)
      project = insert(:project, owner: owner)
      new_owner = insert(:user, email: "bob@john.com")

      attrs = Map.put(@update_attrs, :owner, new_owner)
      assert {:ok, %Project{} = project} = Projects.update_project(project, attrs)
      assert project.financing_type == "internal"
      assert project.name == "some updated name"
      assert project.participation_role == "some updated participation_role"
      assert project.project_id == "some updated project_id"
      assert project.project_type == "international"
      assert project.owner == new_owner
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = insert(:project, owner: insert(:user))
      assert {:error, %Ecto.Changeset{}} = Projects.update_project(project, @invalid_attrs)
      assert project == Projects.get_project(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = insert(:project)
      assert {:ok, %Project{}} = Projects.delete_project(project)
      assert Projects.get_project(project.id) == nil
    end

    test "change_project/1 returns a project changeset" do
      project = insert(:project, owner: insert(:user))
      assert %Ecto.Changeset{} = Projects.change_project(project)
    end
  end
end
