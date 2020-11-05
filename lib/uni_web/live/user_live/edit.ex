defmodule UniWeb.UserLive.Edit do
  use UniWeb, :live_view

  alias Uni.Users

  @impl true
  def mount(%{"id" => id}, session, socket) do
    socket = assign_defaults(socket, session)

    user = Users.get_user(id)

    if user do
      {:ok, assign(socket, :user, user)}
    else
      {:ok,
       socket
       |> put_flash(:error, gettext("User not found"))
       |> push_redirect(to: Routes.user_index_path(socket, :users))}
    end
  end
end
