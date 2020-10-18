defmodule Uni.Faculties.Faculty do
  use Ecto.Schema
  import Ecto.Changeset

  schema "faculties" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(faculty, attrs) do
    faculty
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
