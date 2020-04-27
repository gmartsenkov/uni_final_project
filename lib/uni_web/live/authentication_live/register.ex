defmodule UniWeb.AuthenticationLive.Register do
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

  def handle_event("save", %{"user" => params}, socket) do
    params = Map.put(params, "password", Bcrypt.hash_pwd_salt(params["password"]))

    case Users.create_user(params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User created successfuly")
         |> push_redirect(to: "/login")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
