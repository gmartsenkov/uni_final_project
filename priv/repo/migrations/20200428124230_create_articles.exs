defmodule Uni.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :name, :text
      add :publisher, :text
      add :year, :integer
      add :type, :text
      add :scopus, :boolean, default: false, null: false
      add :wofscience, :boolean, default: false, null: false
      add :owner_id, references(:users)

      timestamps()
    end
  end
end
