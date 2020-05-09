defmodule UniWeb.UsersController do
  use UniWeb, :controller

  alias Uni.Users

  def autocomplete(conn, params) do
    query = Map.get(params, "query", "")

    results =
      Enum.map(Users.autocomplete(query), fn user ->
        %{id: user.id, name: user.name}
      end)

    json(conn, results)
  end
end
