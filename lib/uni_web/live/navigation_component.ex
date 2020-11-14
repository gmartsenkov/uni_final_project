defmodule UniWeb.NavigationComponent do
  use UniWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
