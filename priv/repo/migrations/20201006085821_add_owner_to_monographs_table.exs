defmodule Uni.Repo.Migrations.AddOwnerToMonographsTable do
  use Ecto.Migration

  def change do
    alter table("monographs") do
      add :owner_id, references(:users)
    end
  end
end
