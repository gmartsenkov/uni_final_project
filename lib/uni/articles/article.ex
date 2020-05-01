defmodule Uni.Articles.Article do
  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field :name, :string
    field :publisher, :string
    field :scopus, :boolean, default: false
    field :type, :string
    field :wofscience, :boolean, default: false
    field :year, :integer

    belongs_to(:owner, Uni.Users.User, on_replace: :nilify)

    timestamps()
  end

  @doc false
  def changeset(article, attrs) do
    owner = Map.get(attrs, :owner) || Map.get(attrs, "owner")

    article
    |> cast(attrs, [:name, :publisher, :year, :type, :scopus, :wofscience])
    |> put_assoc(:owner, owner)
    |> validate_required([:name, :publisher, :year, :type, :scopus, :wofscience, :owner])
    |> validate_inclusion(:type, valid_types())
  end

  def valid_types, do: ~w(national international)
end
