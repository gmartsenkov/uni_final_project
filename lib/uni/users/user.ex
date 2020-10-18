defmodule Uni.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Uni.Faculties.Faculty
  alias Uni.Faculties.Department

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string

    field :department_id, :integer
    field :faculty_id, :integer

    has_one(:faculty, Faculty)
    has_one(:department, Department)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password])
    |> validate_required([:name, :email, :password])
    |> unique_constraint(:email)
  end
end
