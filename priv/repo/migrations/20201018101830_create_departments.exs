defmodule Uni.Repo.Migrations.CreateDepartments do
  use Ecto.Migration

  def change do
    create table(:departments) do
      add :name, :string
      add :faculty_id, references(:faculties, on_delete: :nothing)

      timestamps()
    end

    create index(:departments, [:faculty_id])
  end
end
