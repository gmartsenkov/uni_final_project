defmodule Uni.Faculties.Department do
  use Ecto.Schema
  import Ecto.Changeset

  alias Uni.Faculties.Faculty

  schema "departments" do
    field :name, :string

    belongs_to(:faculty, Faculty)
    has_many(:users, Uni.Users.User)

    timestamps()
  end

  @doc false
  def changeset(department, attrs) do
    department
    |> cast(attrs, [:name, :faculty_id])
    |> validate_required([:name, :faculty_id])
  end
end
