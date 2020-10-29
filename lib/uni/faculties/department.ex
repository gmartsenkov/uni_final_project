defmodule Uni.Faculties.Department do
  use Ecto.Schema
  import Ecto.Changeset

  alias Uni.Faculties.Faculty

  schema "departments" do
    field :name, :string

    belongs_to(:faculty, Faculty)

    timestamps()
  end

  @doc false
  def changeset(department, attrs) do
    department
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
