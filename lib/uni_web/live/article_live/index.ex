defmodule UniWeb.ArticleLive.Index do
  use UniWeb, :live_view

  alias Uni.Articles

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)

    result = Articles.paginate_articles()

    {:ok, assign_articles(socket, result)}
  end

  @impl true
  def handle_info({:page_change, page}, socket) do
    result = Articles.paginate_articles(page)

    {:noreply, assign_articles(socket, result)}
  end

  defp assign_articles(socket, result) do
    socket
    |> assign(articles: result.entries)
    |> assign(total_pages: result.total_pages)
    |> assign(page: result.page_number)
  end
end
