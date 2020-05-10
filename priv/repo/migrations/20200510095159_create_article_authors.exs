defmodule Uni.Repo.Migrations.CreateArticleAuthors do
  use Ecto.Migration

  def change do
    create table(:article_authors) do
      add :user_id, references(:users, on_delete: :nothing)
      add :article_id, references(:articles, on_delete: :nothing)

      timestamps()
    end

    create index(:article_authors, [:user_id])
    create index(:article_authors, [:article_id])
  end
end
