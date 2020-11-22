defmodule UniWeb.FacultyLive.FormComponent do
  use UniWeb, :live_component

  alias Uni.Faculties

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(%{faculty: faculty, action: action} = assigns, socket) do
    changeset = Faculties.change_faculty(faculty)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:submit_button, submit_button(action))
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"faculty" => faculty} = params, socket) do
    changeset =
      socket.assigns.faculty
      |> Faculties.change_faculty(faculty)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"faculty" => faculty}, socket) do
    handle_save(socket.assigns.action, faculty, socket)
  end

  defp handle_save(:new, params, socket) do
    case Faculties.create_faculty(params) do
      {:ok, _faculty} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Faculty created successfuly"))
         |> push_redirect(to: Routes.faculty_index_path(socket, :faculties))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp handle_save(:update, params, socket) do
    case Faculties.update_faculty(socket.assigns.faculty, params) do
      {:ok, faculty} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Faculty updated successfuly"))
         |> push_redirect(to: Routes.faculty_edit_path(socket, :faculties, faculty))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp submit_button(:new), do: gettext("Create")
  defp submit_button(:update), do: gettext("Update")
end
