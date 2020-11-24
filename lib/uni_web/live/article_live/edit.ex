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
    |> put_flash(:error, gettext("Article not found"))
    |> push_redirect(to: Routes.article_index_path(socket, :articles))
  end

  defp maybe_get_article(socket, %Article{} = article) do
    user = socket.assigns.current_user

    if user.admin || Enum.member?([article.owner.id | Enum.map(article.authors, &(Map.get(&1, :id)))], user.id) do
      socket
      |> assign(:page_title, "#{gettext("Edit")} - #{article.name}")
      |> assign(:article, article)
      |> assign(:disabled, !user.admin && article.owner.id != user.id)
    else
      maybe_get_article(socket, nil)
    end
  end
end
