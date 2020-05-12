defmodule Uni.Repo.Migrations.CreateConferences do
  use Ecto.Migration

  def change do
    create table(:conferences) do
      add :name, :text
      add :type, :text
      add :reported, :boolean, default: false, null: false
      add :published, :boolean, default: false, null: false
      add :page_start, :integer
      add :page_end, :integer
      add :owner_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:conferences, [:owner_id])
  end
end
