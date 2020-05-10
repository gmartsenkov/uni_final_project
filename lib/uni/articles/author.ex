defmodule Uni.Articles.Author do
  use Ecto.Schema
  alias Uni.Articles.Article
  alias Uni.Users.User
  import Ecto.Changeset

  schema "article_authors" do
    belongs_to(:user, User)
    belongs_to(:article, Article)

    timestamps()
  end

  @doc false
  def changeset(author, attrs) do
    author
    |> cast(attrs, [])
    |> validate_required([])
  end
end
