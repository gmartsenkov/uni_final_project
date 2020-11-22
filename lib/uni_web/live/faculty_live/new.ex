defmodule UniWeb.FacultyLive.New do
  use UniWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)
      |> assign(page_title: gettext("New Faculty"))
      |> assign(:faculty, %Uni.Faculties.Faculty{})

    protected(socket, :admin, fn socket ->
      {:ok,
       socket}
    end)
  end
end
