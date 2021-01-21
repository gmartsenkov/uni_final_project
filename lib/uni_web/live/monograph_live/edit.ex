defmodule UniWeb.MonographLive.Edit do
  use UniWeb, :live_view

  alias Uni.Monographs
  alias Uni.Monographs.Monograph

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign_defaults(socket, session)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply, maybe_get_monograph(socket, Monographs.get_monograph(id))}
  end

  @impl true
  def handle_event("delete", _params, %{assigns: %{disabled: true}} = socket) do
    {:noreply,
     socket
     |> put_flash(:error, gettext("Not allowed"))
     |> push_redirect(to: Routes.monograph_edit_path(socket, :monographs, socket.assigns.monograph.id))}
  end

  @impl true
  def handle_event("delete", _params, socket) do
    case Monographs.delete_monograph(socket.assigns.monograph) do
      {:ok, _monograph} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Monograph deleted successfuly"))
         |> push_redirect(to: Routes.monograph_index_path(socket, :monographs))}
      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, gettext("An error occured"))
         |> push_redirect(to: Routes.monograph_edit_path(socket, :monographs, socket.assigns.monograph.id))}
    end
  end

  defp maybe_get_monograph(socket, nil = _monograph) do
    socket
    |> put_flash(:error, gettext("Monograph not found"))
    |> push_redirect(to: Routes.monograph_index_path(socket, :monographs))
  end

  defp maybe_get_monograph(socket, %Monograph{} = monograph) do
    user = socket.assigns.current_user

    if user.admin || Enum.member?([monograph.owner.id | Enum.map(monograph.authors, &(Map.get(&1, :id)))], user.id) do
      socket
      |> assign(:page_title, "#{gettext("Edit")} - #{monograph.name}")
      |> assign(:monograph, monograph)
      |> assign(:disabled, !user.admin && monograph.owner.id != user.id)
    else
      maybe_get_monograph(socket, nil)
    end
  end
end
