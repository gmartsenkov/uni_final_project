defmodule Uni.Repo do
  use Ecto.Repo,
    otp_app: :uni,
    adapter: Ecto.Adapters.Postgres
end
