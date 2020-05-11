defmodule Uni.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :text
      add :project_id, :text
      add :project_type, :text
      add :financing_type, :text
      add :participation_role, :text
      add :owner_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:projects, [:owner_id])
  end
end
