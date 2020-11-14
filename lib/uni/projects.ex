defmodule Uni.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias Uni.Repo

  alias Uni.Projects.Project

  def filter(query, "faculty", "all"), do: query

  def filter(query, "faculty", faculty_id) do
    query
    |> join(:inner, [a], owner in assoc(a, :owner))
    |> where([projects, users], users.faculty_id == ^faculty_id)
  end

  def filter(query, "department", "all"), do: query

  def filter(query, "department", department_id) do
    query
    |> join(:inner, [a], owner in assoc(a, :owner))
    |> where([projects, users], users.department_id == ^department_id)
  end

  def filter(query, "project_type", "all"), do: query
  def filter(query, "project_type", type), do: query |> where(project_type: ^type)

  def filter(query, "financing_type", "all"), do: query
  def filter(query, "financing_type", type), do: query |> where(financing_type: ^type)

  def filter(query, _type, _value), do: query

  def filter(query, [{type, value} | tail]) do
    query
    |> filter(type, value)
    |> filter(tail)
  end

  def filter(query, _filters = []), do: query

  def count(query), do: Repo.aggregate(query, :count)

  def graph(query) do
    query
    |> preload(:owner)
    |> Repo.all()
  end

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Repo.all(Project)
  end

  @doc """
  Returns a paginated list of projects for an owner.

  ## Examples

      iex> paginate_projects(owner_id, page \\ 1, page_size \\ 10)
      %Scrivener.Page{entries: [...], total_pages: 1, total_entries: 2...}

  """
  def paginate_projects(owner_id, query \\ "", page \\ 1, page_size \\ 10) do
    search(query)
    |> where(owner_id: ^owner_id)
    |> order_by(desc: :updated_at)
    |> preload(:owner)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  defp search(""), do: Project
  defp search(query), do: from(a in Project, where: ilike(a.name, ^"%#{query}%"))

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project(123)
      %Project{}

      iex> get_project(456)
      nil

  """
  def get_project(id), do: Project |> Repo.get(id) |> Repo.preload(:owner)

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end
end
