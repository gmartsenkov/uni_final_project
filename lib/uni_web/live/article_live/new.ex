defmodule UniWeb.ArticleLive.New do
  use UniWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign_defaults(socket, session)}
  end
end
