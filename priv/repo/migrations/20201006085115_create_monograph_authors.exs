defmodule Uni.Repo.Migrations.CreateMonographAuthors do
  use Ecto.Migration

  def change do
    create table(:monograph_authors) do
      add :user_id, references(:users, on_delete: :nothing)
      add :monograph_id, references(:monographs, on_delete: :nothing)

      timestamps()
    end
  end
end
