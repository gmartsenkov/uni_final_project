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

  @impl true
  def handle_event("delete", _params, socket) do
    case Projects.delete_project(socket.assigns.project) do
      {:ok, _project} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Project deleted successfuly"))
         |> push_redirect(to: Routes.project_index_path(socket, :projects))}
      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, gettext("An error occured"))
         |> push_redirect(to: Routes.project_edit_path(socket, :projects, socket.assigns.project.id))}
    end
  end

  defp maybe_get_project(socket, nil = _project) do
    socket
    |> put_flash(:error, gettext("Project not found"))
    |> push_redirect(to: Routes.project_index_path(socket, :projects))
  end

  defp maybe_get_project(socket, %Project{} = project) do
    user = socket.assigns.current_user

    if user.admin || project.owner.id == user.id do
      socket
      |> assign(:page_title, "#{gettext("Edit")} - #{project.name}")
      |> assign(:project, project)
    else
      maybe_get_project(socket, nil)
    end
  end
end
