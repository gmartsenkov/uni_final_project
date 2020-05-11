defmodule UniWeb.ProjectLive.Edit do
  use UniWeb, :live_view

  alias Uni.Projects
  alias Uni.Projects.Project

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign_defaults(socket, session)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply, maybe_get_project(socket, Projects.get_project(id))}
  end

  defp maybe_get_project(socket, nil = _project) do
    socket
    |> put_flash(:error, gettext("Project not found"))
    |> push_redirect(to: Routes.project_index_path(socket, :projects))
  end

  defp maybe_get_project(socket, %Project{} = project) do
    socket
    |> assign(:page_title, "#{gettext("Edit")} - #{project.name}")
    |> assign(:project, project)
  end
end
