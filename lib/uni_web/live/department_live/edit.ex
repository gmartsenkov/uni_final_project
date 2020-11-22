defmodule UniWeb.DepartmentLive.Edit do
  use UniWeb, :live_view

  alias Uni.Faculties

  @impl true
  def mount(%{"id" => id}, session, socket) do
    socket = assign_defaults(socket, session)

    protected(socket, :admin, fn socket ->
      department = Faculties.department_by_id(id)

      if department do
        {:ok, assign(socket, :department, department)}
      else
        {:ok,
         socket
         |> put_flash(:error, gettext("Department not found"))
         |> push_redirect(to: Routes.faculty_index_path(socket, :faculties))}
      end
    end)
  end
end
