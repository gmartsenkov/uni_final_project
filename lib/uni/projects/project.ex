defmodule Uni.Projects.Project do
  use Ecto.Schema
  alias Uni.Users.User
  import Ecto.Changeset

  schema "projects" do
    field :financing_type, :string
    field :name, :string
    field :participation_role, :string
    field :project_id, :string
    field :project_type, :string

    belongs_to(:owner, User, on_replace: :nilify)
    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    owner = Map.get(attrs, :owner) || Map.get(attrs, "owner")

    project
    |> cast(attrs, [:name, :project_id, :project_type, :financing_type, :participation_role])
    |> put_assoc(:owner, owner)
    |> validate_required([
      :name,
      :project_id,
      :project_type,
      :financing_type,
      :participation_role,
      :owner
    ])
  end
end
