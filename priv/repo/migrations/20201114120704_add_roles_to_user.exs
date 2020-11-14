defmodule Uni.Repo.Migrations.AddRolesToUser do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :admin, :boolean, default: false
      add :head_faculty, :boolean, default: false
      add :head_department, :boolean, default: false
    end
  end
end
