defmodule UniWeb.MonographLive.Index do
  use UniWeb, :live_view

  alias Uni.Monographs
  alias Uni.Monographs.Monograph

  @impl true
  def mount(params, session, socket) do
    socket = assign_defaults(socket, session)
    page = Map.get(params, "page", 1)
    per_page = Map.get(params, "per_page", "10")
    query = Map.get(params, "query", "")

    result =
      Monograph
      |> Monographs.filter("user", socket.assigns.current_user.id)
      |> Monographs.filter("query", query)
      |> Monographs.paginate(page, per_page)

    {:ok,
     socket
     |> assign_monographs(result)
     |> assign(page_title: gettext("Monographs"))
     |> assign(per_page: per_page)
     |> assign(query: query)}
  end

  @impl true
  def handle_info({:page_change, page}, %{assigns: assigns} = socket) do
    result =
      Monograph
      |> Monographs.filter("user", socket.assigns.current_user.id)
      |> Monographs.filter("query", assigns.query)
      |> Monographs.paginate(page, assigns.per_page)

    {:noreply,
     socket
     |> assign_monographs(result)
     |> update_params(result)}
  end

  @impl true
  def handle_event(
        "filter",
        %{"per_page" => per_page, "query" => query},
        %{assigns: assigns} = socket
      ) do
    result =
      Monograph
      |> Monographs.filter("user", socket.assigns.current_user.id)
      |> Monographs.filter("query", query)
      |> Monographs.paginate(assigns.page, per_page)

    {:noreply,
     socket
     |> assign_filters(per_page, query)
     |> assign_monographs(result)
     |> update_params(result)}
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end

  defp assign_monographs(socket, result) do
    socket
    |> assign(monographs: result.entries)
    |> assign(total_pages: result.total_pages)
    |> assign(total: result.total_entries)
    |> assign(page: result.page_number)
  end

  defp assign_filters(socket, per_page, query) do
    socket
    |> assign(per_page: per_page)
    |> assign(query: query)
  end

  defp update_params(%{assigns: assigns} = socket, result) do
    socket
    |> push_patch(
      to:
        Routes.monograph_index_path(socket, :monographs,
          page: result.page_number,
          per_page: assigns.per_page,
          query: assigns.query
        )
    )
  end
end
