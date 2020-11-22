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
end
