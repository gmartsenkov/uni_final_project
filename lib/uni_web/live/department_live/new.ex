defmodule UniWeb.DepartmentLive.New do
  use UniWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)
      |> assign(page_title: gettext("New Department"))
      |> assign(:department, %Uni.Faculties.Department{})

    protected(socket, :admin, fn socket ->
      {:ok,
       socket}
    end)
  end
end
