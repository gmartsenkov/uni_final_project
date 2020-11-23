defmodule UniWeb.FacultyLive.Edit do
  use UniWeb, :live_view

  alias Uni.Faculties
  alias Uni.Faculties.Faculty

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)

    protected(socket, :admin, fn socket ->
      {:ok,
       socket}
    end)
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply, maybe_get_faculty(socket, Faculties.by_id(id))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    department = Faculties.department_by_id(id)
    Faculties.delete_department(department)

    {:noreply,
     socket
     |> put_flash(:info, gettext("Department deleted successfuly"))
     |> push_redirect(to: Routes.faculty_edit_path(socket, :faculties, department.faculty_id))}
  end

  defp maybe_get_faculty(socket, nil = _faculty) do
    socket
    |> put_flash(:error, gettext("Faculty not found"))
    |> push_redirect(to: Routes.faculty_index_path(socket, :faculties))
  end

  defp maybe_get_faculty(socket, %Faculty{} = faculty) do
    socket
    |> assign(:page_title, "#{gettext("Edit")} - #{faculty.name}")
    |> assign(:faculty, faculty)
  end

  defp important_people(users) do
    users
    |> Enum.filter(fn u -> u.head_department || u.head_faculty end)
    |> Enum.sort(fn u, _ -> u.head_faculty end)
  end

  defp deleteable?(faculty) do
    Enum.empty?(faculty.users)
  end
end
