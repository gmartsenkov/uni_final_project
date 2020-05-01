defmodule UniWeb.ArticleLive.New do
  use UniWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign_defaults(socket, session)
      |> assign(:article, %Uni.Articles.Article{})

    {:ok, socket}
  end
end
