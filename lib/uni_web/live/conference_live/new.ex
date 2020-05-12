defmodule UniWeb.ConferenceLive.New do
  use UniWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign_defaults(socket, session)
      |> assign(page_title: gettext("New Conference"))
      |> assign(:conference, %Uni.Conferences.Conference{})

    {:ok, socket}
  end
end
