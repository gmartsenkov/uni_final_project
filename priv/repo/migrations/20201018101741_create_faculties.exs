defmodule Uni.Repo.Migrations.CreateFaculties do
  use Ecto.Migration

  def change do
    create table(:faculties) do
      add :name, :string

      timestamps()
    end

  end
end
