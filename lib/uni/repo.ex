defmodule Uni.Repo do
  use Ecto.Repo,
    otp_app: :uni,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10
end
