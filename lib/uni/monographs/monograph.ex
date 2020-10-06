defmodule Uni.Monographs.Monograph do
  use Ecto.Schema
  import Ecto.Changeset

  schema "monographs" do
    field :name, :string
    field :publisher, :string
    field :year, :integer

    timestamps()
  end

  @doc false
  def changeset(monograph, attrs) do
    monograph
    |> cast(attrs, [:name, :publisher, :year])
    |> validate_required([:name, :publisher, :year])
  end
end
