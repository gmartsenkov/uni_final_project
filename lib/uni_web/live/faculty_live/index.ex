defmodule UniWeb.FacultyLive.Index do
  use UniWeb, :live_view

  alias Uni.Faculties
  alias Uni.Faculties.Faculty

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)

    protected(socket, :admin, fn socket ->
      {:ok,
       socket
       |> assign(:page_title, gettext("Faculties"))}
    end)
  end

  @impl true
  def handle_params(params, _uri, socket) do
    result = Faculties.faculties()

    {:noreply,
     socket
     |> assign(:faculties, result)
     |> assign(:filters, Filters.changeset(params))
     |> assign(:total, Enum.count(result))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    faculty = Faculties.by_id(id)
    Faculties.delete_faculty(faculty)

    {:noreply,
     socket
     |> put_flash(:info, gettext("Faculty deleted successfuly"))
     |> push_redirect(to: Routes.faculty_index_path(socket, :faculties))}
  end

  def deleteable?(faculty) do
    Enum.empty?(faculty.departments)
  end
end
