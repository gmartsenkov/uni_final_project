defmodule UniWeb.ArticleLive.FormComponent do
  use UniWeb, :live_component

  alias Uni.Articles

  @impl true
  def mount(socket) do
    valid_types = [
      {gettext("National"), "national"},
      {gettext("International"), "international"}
    ]

    socket =
      socket
      |> assign(valid_types: valid_types)
      |> assign(author_search: "")
      |> assign(selected: [])

    {:ok, socket}
  end

  @impl true
  def update(%{article: article, action: action} = assigns, socket) do
    changeset = Articles.change_article(article)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_authors(assigns)
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

  def handle_event("save", _params, %{assigns: %{disabled: true}} = socket) do
    {:noreply,
     socket
     |> put_flash(:error, gettext("Not allowed"))
     |> push_redirect(to: Routes.article_edit_path(socket, :articles, socket.assigns.article.id))}
  end

  def handle_event("save", %{"article" => article} = params, socket) do
    article =
      article
      |> Map.put("authors", get_authors(params["authors"]))
      |> Map.put("owner", socket.assigns.user)

    handle_save(socket.assigns.action, article, socket)
  end

  defp handle_save(:new, params, socket) do
    case Articles.create_article(params) do
      {:ok, _article} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Article created successfully"))
         |> push_redirect(to: Routes.article_index_path(socket, :articles))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp handle_save(:update, params, socket) do
    case Articles.update_article(socket.assigns.article, params) do
      {:ok, article} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Article updated successfully"))
         |> push_redirect(to: Routes.article_edit_path(socket, :articles, article))}

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

  defp assign_authors(socket, %{article: %{authors: authors}}) do
    assign(
      socket,
      :authors,
      Enum.map(authors, fn author ->
        %{"id" => author.id, "text" => author.name}
      end)
    )
   end

  defp get_authors(authors) when is_list(authors), do: Uni.Users.get_users(authors)
  defp get_authors(_), do: []
  defp submit_button(:new), do: gettext("Create")
  defp submit_button(:update), do: gettext("Update")
end
