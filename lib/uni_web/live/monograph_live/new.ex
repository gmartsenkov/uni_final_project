defmodule UniWeb.MonographLive.New do
  use UniWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign_defaults(socket, session)
      |> assign(page_title: gettext("New Monograph"))
      |> assign(:monograph, %Uni.Monographs.Monograph{authors: []})

    {:ok, socket}
  end
end
