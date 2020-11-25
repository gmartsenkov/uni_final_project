defmodule UniWeb.MonographLive.FormComponent do
  use UniWeb, :live_component

  alias Uni.Monographs

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(author_search: "")
      |> assign(selected: [])

    {:ok, socket}
  end

  @impl true
  def update(%{monograph: monograph, action: action} = assigns, socket) do
    changeset = Monographs.change_monograph(monograph)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_authors(assigns)
     |> assign(:submit_button, submit_button(action))
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"monograph" => monograph} = params, socket) do
    changeset =
      socket.assigns.monograph
      |> Monographs.change_monograph(Map.put(monograph, "owner", socket.assigns.user))
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
     |> push_redirect(to: Routes.monograph_edit_path(socket, :monographs, socket.assigns.monograph.id))}
  end

  def handle_event("save", %{"monograph" => monograph} = params, socket) do
    monograph =
      monograph
      |> Map.put("authors", get_authors(params["authors"]))
      |> Map.put("owner", socket.assigns.user)

    handle_save(socket.assigns.action, monograph, socket)
  end

  defp handle_save(:new, params, socket) do
    case Monographs.create_monograph(params) do
      {:ok, _monograph} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Monograph created successfuly"))
         |> push_redirect(to: Routes.monograph_index_path(socket, :monographs))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp handle_save(:update, params, socket) do
    case Monographs.update_monograph(socket.assigns.monograph, params) do
      {:ok, monograph} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Monograph updated successfuly"))
         |> push_redirect(to: Routes.monograph_edit_path(socket, :monographs, monograph))}

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

  defp assign_authors(socket, %{monograph: %{authors: authors}}) do
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
