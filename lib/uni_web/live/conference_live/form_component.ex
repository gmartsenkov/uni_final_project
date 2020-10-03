defmodule UniWeb.ConferenceLive.FormComponent do
  use UniWeb, :live_component

  alias Uni.Conferences

  @impl true
    def mount(socket) do
    socket =
      socket
      |> assign(author_search: "")
      |> assign(selected: [])

    {:ok, socket}
  end

  @impl true
  def update(%{conference: conference, action: action} = assigns, socket) do
    changeset = Conferences.change_conference(conference)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:submit_button, submit_button(action))
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"conference" => conference} = params, socket) do
    changeset =
      socket.assigns.conference
      |> Conferences.change_conference(Map.put(conference, "owner", socket.assigns.user))
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign(:changeset, changeset)
      |> assign(:author_search, Map.get(params, "author_search", ""))

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"conference" => conference}, socket) do
    conference =
      conference
      |> Map.put("owner", socket.assigns.user)

    handle_save(socket.assigns.action, conference, socket)
  end

  defp handle_save(:new, params, socket) do
    case Conferences.create_conference(params) do
      {:ok, _conference} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Conference created successfuly"))
         |> push_redirect(to: Routes.conference_index_path(socket, :conferences))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp handle_save(:update, params, socket) do
    case Conferences.update_conference(socket.assigns.conference, params) do
      {:ok, conference} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Conference updated successfuly"))
         |> push_redirect(to: Routes.conference_edit_path(socket, :conferences, conference))}

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

  defp submit_button(:new), do: gettext("Create")
  defp submit_button(:update), do: gettext("Update")

  defp valid_types,
    do: [
      {gettext("National"), "national"},
      {gettext("International"), "international"}
    ]
end
