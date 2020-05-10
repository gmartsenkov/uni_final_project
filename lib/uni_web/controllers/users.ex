defmodule UniWeb.UsersController do
  use UniWeb, :controller

  alias Uni.Users

  def autocomplete(conn, %{"query" => query}) when is_binary(query) do
    users = if String.length(query) > 2, do: Users.autocomplete(query), else: []

    results =
      Enum.map(users, fn user ->
        %{id: user.id, name: user.name}
      end)

    json(conn, results)
  end

  def autocomplete(conn, _params), do: json(conn, [])
end
