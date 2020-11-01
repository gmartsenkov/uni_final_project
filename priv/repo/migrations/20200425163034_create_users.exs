defmodule Uni.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :"text COLLATE \"en_US\"", null: false
      add :email, :string, unique: true
      add :password, :text, null: false

      timestamps()
    end
  end
end
