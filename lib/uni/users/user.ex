defmodule Uni.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Uni.Faculties.Faculty
  alias Uni.Faculties.Department

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string

    belongs_to(:faculty, Faculty)
    belongs_to(:department, Department)

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
