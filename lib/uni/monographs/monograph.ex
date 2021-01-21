defmodule Uni.Monographs.Monograph do
  use Ecto.Schema
  import Ecto.Changeset

  alias Uni.Users.User
  alias Uni.Monographs.Author

  schema "monographs" do
    field :name, :string
    field :publisher, :string
    field :year, :integer

    belongs_to(:owner, User, on_replace: :nilify)
    many_to_many(:authors, User, join_through: Author, on_replace: :delete, on_delete: :delete_all)

    timestamps()
  end

  @doc false
  def changeset(monograph, attrs) do
    owner = Map.get(attrs, :owner) || Map.get(attrs, "owner")
    authors = Map.get(attrs, :authors) || Map.get(attrs, "authors") || []

    monograph
    |> Uni.Repo.preload(:authors)
    |> cast(attrs, [:name, :publisher, :year])
    |> put_assoc(:owner, owner)
    |> put_assoc(:authors, authors)
    |> validate_required([:name, :publisher, :year, :owner])
  end
end
