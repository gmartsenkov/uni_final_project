defmodule UniWeb.UserLive.New do
  use UniWeb, :live_view

  alias Uni.Users.User

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)

    {:ok, assign(socket, :user, %User{})}
  end
end
