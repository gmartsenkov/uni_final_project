defmodule Uni.Faculties do
  @moduledoc """
  The Faculties context.
  """

  import Ecto.Query, warn: false
  alias Uni.Repo

  alias Uni.Faculties.Faculty
  alias Uni.Faculties.Department

  def faculties(), do: Repo.all(Faculty)
  def faculties_graph(), do: Faculty |> preload(:departments) |> preload(:users) |> Repo.all()

  def by_id(id) do
    where(Faculty, id: ^id) |> preload(:departments) |> preload(:users) |> Repo.one
  end

  def department_by_id(id) do
    where(Department, id: ^id) |> Repo.one
  end

  def departments(faculty) do
    Department |> where(faculty_id: ^faculty.id) |> Repo.all()
  end

  def faculty_by_name(name) do
    Faculty
    |> where(name: ^name)
    |> Repo.one()
  end

  def department_by_name(name) do
    Department
    |> where(name: ^name)
    |> Repo.one()
  end

  def create_faculty(attrs \\ %{}) do
    %Faculty{}
    |> Faculty.changeset(attrs)
    |> Repo.insert()
  end

  def update_faculty(%Faculty{} = faculty, attrs) do
    faculty
    |> Faculty.changeset(attrs)
    |> Repo.update()
  end

  def change_faculty(%Faculty{} = faculty, attrs \\ %{}) do
    Faculty.changeset(faculty, attrs)
  end

  def delete_faculty(%Faculty{} = faculty) do
    Repo.delete(faculty)
  end

  def create_department(attrs \\ %{}) do
    %Department{}
    |> Department.changeset(attrs)
    |> Repo.insert()
  end

  def update_department(%Department{} = department, attrs) do
    department
    |> Department.changeset(attrs)
    |> Repo.update()
  end

  def change_department(%Department{} = department, attrs \\ %{}) do
    Department.changeset(department, attrs)
  end

  def delete_department(%Department{} = department) do
    Repo.delete(department)
  end
end
