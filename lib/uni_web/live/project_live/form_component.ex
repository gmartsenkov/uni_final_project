defmodule UniWeb.ProjectLive.FormComponent do
  use UniWeb, :live_component

  alias Uni.Projects

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(author_search: "")
      |> assign(selected: [])

    {:ok, socket}
  end

  @impl true
  def update(%{project: project, action: action} = assigns, socket) do
    changeset = Projects.change_project(project)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:submit_button, submit_button(action))
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"project" => project} = params, socket) do
    changeset =
      socket.assigns.project
      |> Projects.change_project(Map.put(project, "owner", socket.assigns.user))
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign(:changeset, changeset)
      |> assign(:author_search, Map.get(params, "author_search", ""))

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"project" => project} = params, socket) do
    project =
      project
      |> Map.put("authors", get_authors(params["authors"]))
      |> Map.put("owner", socket.assigns.user)

    handle_save(socket.assigns.action, project, socket)
  end

  defp handle_save(:new, params, socket) do
    case Projects.create_project(params) do
      {:ok, _project} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Project created successfuly"))
         |> push_redirect(to: Routes.project_index_path(socket, :projects))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp handle_save(:update, params, socket) do
    case Projects.update_project(socket.assigns.project, params) do
      {:ok, project} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Project updated successfuly"))
         |> push_redirect(to: Routes.project_edit_path(socket, :projects, project))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_info({:add_author, author}, socket) do
    {:noreply,
     socket
     |> assign(:selected, socket.assigns.selected ++ [author])
     |> assign(:author_search, "")}
  end

  defp get_authors(authors) when is_list(authors), do: Uni.Users.get_users(authors)
  defp get_authors(_), do: []
  defp submit_button(:new), do: gettext("Create")
  defp submit_button(:update), do: gettext("Update")

  defp valid_project_types,
    do: [
      {gettext("National"), "national"},
      {gettext("International"), "international"}
    ]

  defp valid_financing_types,
    do: [
      {gettext("Internal"), "internal"},
      {gettext("External"), "external"}
    ]
end
