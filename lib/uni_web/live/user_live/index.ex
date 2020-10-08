defmodule UniWeb.UserLive.Index do
  use UniWeb, :live_view
  alias Uni.Users
  alias UniWeb.Helpers.Errors

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)

    {:ok,
     socket
     |> assign(:page_title, gettext("Users"))}
  end
end
