defmodule UniWeb.ConferenceLive.Edit do
  use UniWeb, :live_view

  alias Uni.Conferences
  alias Uni.Conferences.Conference

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign_defaults(socket, session)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply, maybe_get_conference(socket, Conferences.get_conference(id))}
  end

  defp maybe_get_conference(socket, nil = _conference) do
    socket
    |> put_flash(:error, gettext("Conference not found"))
    |> push_redirect(to: Routes.conference_index_path(socket, :conferences))
  end

  defp maybe_get_conference(socket, %Conference{} = conference) do
    socket
    |> assign(:page_title, "#{gettext("Edit")} - #{conference.name}")
    |> assign(:conference, conference)
  end
end
