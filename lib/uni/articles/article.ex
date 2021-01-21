defmodule Uni.Articles.Article do
  use Ecto.Schema
  alias Uni.Users.User
  alias Uni.Articles.Author
  import Ecto.Changeset

  schema "articles" do
    field :name, :string
    field :publisher, :string
    field :scopus, :boolean, default: false
    field :type, :string
    field :wofscience, :boolean, default: false
    field :year, :integer

    belongs_to(:owner, User, on_replace: :nilify)
    many_to_many(:authors, User, join_through: Author, on_replace: :delete, on_delete: :delete_all)

    timestamps()
  end

  @doc false
  def changeset(article, attrs) do
    owner = Map.get(attrs, :owner) || Map.get(attrs, "owner")
    authors = Map.get(attrs, :authors) || Map.get(attrs, "authors") || []

    article
    |> Uni.Repo.preload(:authors)
    |> cast(attrs, [:name, :publisher, :year, :type, :scopus, :wofscience])
    |> put_assoc(:owner, owner)
    |> put_assoc(:authors, authors)
    |> validate_required([:name, :publisher, :year, :type, :scopus, :wofscience, :owner])
    |> validate_inclusion(:type, valid_types())
  end

  def valid_types, do: ~w(national international)
end
