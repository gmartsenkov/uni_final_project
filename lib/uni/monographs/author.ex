defmodule Uni.Monographs.Author do
  use Ecto.Schema
  import Ecto.Changeset
  alias Uni.Monographs.Monograph
  alias Uni.Users.User

  schema "monograph_authors" do
    belongs_to(:user, User)
    belongs_to(:monograph, Monograph)

    timestamps()
  end

  @doc false
  def changeset(author, attrs) do
    author
    |> cast(attrs, [:user_id, :monograph_id])
    |> validate_required([:user_id, :monograph_id])
  end
end
