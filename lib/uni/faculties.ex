defmodule Uni.Faculties do
  @moduledoc """
  The Faculties context.
  """

  import Ecto.Query, warn: false
  alias Uni.Repo

  alias Uni.Faculties.Faculty
  alias Uni.Faculties.Department

  def faculties(), do: Repo.all(Faculty)

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
end
