defmodule Uni.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Uni.Faculties.Faculty
  alias Uni.Faculties.Department

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string
    field :admin, :boolean
    field :head_faculty, :boolean
    field :head_department, :boolean

    belongs_to(:faculty, Faculty)
    belongs_to(:department, Department)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :name,
      :email,
      :password,
      :faculty_id,
      :department_id,
      :admin,
      :head_faculty,
      :head_department
    ])
    |> validate_required([:name, :email, :password, :faculty_id, :department_id])
    |> unique_constraint(:email)
  end
end
