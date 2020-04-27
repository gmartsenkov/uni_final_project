defmodule UniWeb.AuthenticationLive.Login do
  use UniWeb, :live_view

  alias Uni.Users
  alias Uni.Users.User

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{changeset: Users.change_user(%User{})})}
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      %User{}
      |> Users.change_user(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end
end
