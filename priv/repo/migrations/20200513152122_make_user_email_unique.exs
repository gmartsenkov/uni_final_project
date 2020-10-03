defmodule Uni.Repo.Migrations.MakeUserEmailUnique do
  use Ecto.Migration

  def change do
    create index("users", [:email], unique: true)
  end
end
