defmodule UniWeb.UsersController do
  use UniWeb, :controller

  alias Uni.Users

  def autocomplete(conn, %{"query" => query}) do
    results =
      Enum.map(Users.autocomplete(query), fn user ->
        %{id: user.id, name: user.name}
      end)

    json(conn, results)
  end
end
