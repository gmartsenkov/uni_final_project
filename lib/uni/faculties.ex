defmodule Uni.Faculties do
  @moduledoc """
  The Faculties context.
  """

  import Ecto.Query, warn: false
  alias Uni.Repo

  alias Uni.Faculties.Faculty
  alias Uni.Faculties.Department

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
