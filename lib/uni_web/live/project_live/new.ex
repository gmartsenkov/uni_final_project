defmodule UniWeb.ProjectLive.New do
  use UniWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign_defaults(socket, session)
      |> assign(page_title: gettext("New Project"))
      |> assign(:project, %Uni.Projects.Project{})

    {:ok, socket}
  end
end
