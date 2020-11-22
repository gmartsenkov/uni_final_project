defmodule UniWeb.DepartmentLive.FormComponent do
  use UniWeb, :live_component

  alias Uni.Faculties

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(%{department: department, action: action} = assigns, socket) do
    changeset = Faculties.change_department(department)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(faculties: faculties())
     |> assign(:submit_button, submit_button(action))
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"department" => department}, socket) do
    changeset =
      socket.assigns.department
      |> Faculties.change_department(department)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"department" => department}, socket) do
    handle_save(socket.assigns.action, department, socket)
  end

  defp handle_save(:new, params, socket) do
    case Faculties.create_department(params) do
      {:ok, department} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Department created successfuly"))
         |> push_redirect(to: Routes.faculty_edit_path(socket, :faculties, department.faculty_id))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp handle_save(:update, params, socket) do
    case Faculties.update_department(socket.assigns.department, params) do
      {:ok, department} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Department updated successfuly"))
         |> push_redirect(to: Routes.department_edit_path(socket, :faculties, department))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp submit_button(:new), do: gettext("Create")
  defp submit_button(:update), do: gettext("Update")

  defp faculties() do
    Faculties.faculties()
    |> Enum.map(fn f -> {f.name, f.id} end)
  end
end
