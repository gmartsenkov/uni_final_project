defmodule UniWeb.ArticleLive.FormComponent do
  use UniWeb, :live_component

  alias Uni.Articles

  @impl true
  def mount(socket) do
    valid_types = [National: "national", International: "international"]

    socket =
      socket
      |> assign(valid_types: valid_types)
      |> assign(author_search: "")
      |> assign(selected: [])
      |> assign(authors: [])

    {:ok, socket}
  end

  @impl true
  def update(%{article: article, action: action} = assigns, socket) do
    changeset = Articles.change_article(article)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:submit_button, submit_button(action))
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"article" => article} = params, socket) do
    changeset =
      socket.assigns.article
      |> Articles.change_article(Map.put(article, "owner", socket.assigns.user))
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign(:changeset, changeset)
      |> assign(:author_search, Map.get(params, "author_search", ""))

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("add_author", %{"author" => author}, socket) do
    {:noreply,
     socket
     |> assign(:authors, socket.assigns.authors ++ [author])}
  end

  def handle_event("save", %{"article" => params}, socket) do
    handle_save(socket.assigns.action, params, socket)
  end

  defp handle_save(:new, params, socket) do
    attrs = Map.put(params, "owner", socket.assigns.user)

    case Articles.create_article(attrs) do
      {:ok, _article} ->
        {:noreply,
         socket
         |> put_flash(:info, "Article created successfuly")
         |> push_redirect(to: Routes.article_index_path(socket, :articles))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp handle_save(:update, params, socket) do
    params = Map.put(params, "owner", socket.assigns.article.owner)

    case Articles.update_article(socket.assigns.article, params) do
      {:ok, _article} ->
        {:noreply,
         socket
         |> put_flash(:info, "Article updated successfuly")
         |> push_redirect(to: Routes.article_index_path(socket, :articles))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_info({:add_author, author}, socket) do
    {:noreply,
     socket
     |> assign(:selected, socket.assigns.selected ++ [author])
     |> assign(:author_search, "")}
  end

  defp submit_button(:new), do: "Create"
  defp submit_button(:update), do: "Update"
end
