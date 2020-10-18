defmodule Uni.Repo.Migrations.AddFacultyDepartmentToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :faculty_id, references(:faculties)
      add :department_id, references(:departments)
    end
  end
end
