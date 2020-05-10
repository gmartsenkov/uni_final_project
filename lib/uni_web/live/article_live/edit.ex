defmodule UniWeb.ArticleLive.Edit do
  use UniWeb, :live_view

  alias Uni.Articles
  alias Uni.Articles.Article

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign_defaults(socket, session)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply, maybe_get_article(socket, Articles.get_article(id))}
  end

  defp maybe_get_article(socket, nil = _article) do
    socket
    |> put_flash(:error, "Article not found")
    |> push_redirect(to: Routes.article_index_path(socket, :articles))
  end

  defp maybe_get_article(socket, %Article{} = article) do
    socket
    |> assign(:page_title, "Edit - #{article.name}")
    |> assign(:article, article)
  end
end
