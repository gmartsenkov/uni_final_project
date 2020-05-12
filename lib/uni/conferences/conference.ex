defmodule Uni.Conferences.Conference do
  use Ecto.Schema
  import Ecto.Changeset

  schema "conferences" do
    field :name, :string
    field :page_end, :integer
    field :page_start, :integer
    field :published, :boolean, default: false
    field :reported, :boolean, default: false
    field :type, :string
    field :owner_id, :id

    timestamps()
  end

  @doc false
  def changeset(conference, attrs) do
    conference
    |> cast(attrs, [:name, :type, :reported, :published, :page_start, :page_end])
    |> validate_required([:name, :type, :reported, :published, :page_start, :page_end])
  end
end
