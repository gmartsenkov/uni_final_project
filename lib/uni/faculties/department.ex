defmodule Uni.Faculties.Department do
  use Ecto.Schema
  import Ecto.Changeset

  schema "departments" do
    field :name, :string
    field :faculty_id, :id

    timestamps()
  end

  @doc false
  def changeset(department, attrs) do
    department
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
