defmodule UniWeb.ArticleLive.Index do
  use UniWeb, :live_view

  alias Uni.Articles

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)
    {:ok, assign(socket, %{articles: Articles.list_articles()})}
  end
end
