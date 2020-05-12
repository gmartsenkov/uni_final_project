defmodule Uni.Conferences.Conference do
  use Ecto.Schema
  alias Uni.Users.User
  import Ecto.Changeset

  schema "conferences" do
    field :name, :string
    field :page_end, :integer
    field :page_start, :integer
    field :published, :boolean, default: false
    field :reported, :boolean, default: false
    field :type, :string

    belongs_to(:owner, User, on_replace: :nilify)

    timestamps()
  end

  @doc false
  def changeset(conference, attrs) do
    owner = Map.get(attrs, :owner) || Map.get(attrs, "owner")

    conference
    |> cast(attrs, [:name, :type, :reported, :published, :page_start, :page_end])
    |> put_assoc(:owner, owner)
    |> validate_required([:name, :type, :reported, :published, :page_start, :page_end, :owner])
  end
end
