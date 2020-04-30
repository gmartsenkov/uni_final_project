defmodule Uni.Articles.Article do
  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field :name, :string
    field :owner_id, :integer
    field :publisher, :string
    field :scopus, :boolean, default: false
    field :type, :string
    field :wofscience, :boolean, default: false
    field :year, :integer

    timestamps()
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:name, :publisher, :year, :type, :scopus, :wofscience, :owner_id])
    |> validate_required([:name, :publisher, :year, :type, :scopus, :wofscience, :owner_id])
    |> validate_inclusion(:type, valid_types())
  end

  def valid_types, do: ~w(national international)
end
