defmodule UniWeb.NavigationLive do
  use UniWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign(socket, :navigation, session["navigation"])}
  end
end
