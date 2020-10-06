defmodule Uni.Repo.Migrations.CreateMonographs do
  use Ecto.Migration

  def change do
    create table(:monographs) do
      add :name, :string
      add :publisher, :string
      add :year, :integer

      timestamps()
    end

  end
end
