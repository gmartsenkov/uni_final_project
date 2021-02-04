defmodule UniWeb.ConferenceLive.Index do
  use UniWeb, :live_view

  alias Uni.Conferences

  @impl true
  def mount(params, session, socket) do
    socket = assign_defaults(socket, session)
    page = Map.get(params, "page", 1)
    per_page = Map.get(params, "per_page", "10")
    query = Map.get(params, "query", "")

    result =
      Conferences.paginate_conferences(socket.assigns.current_user.id, query, page, per_page)

    {:ok,
     socket
     |> assign_conferences(result)
     |> assign(page_title: gettext("Conferences"))
     |> assign(per_page: per_page)
     |> assign(query: query)}
  end

  @impl true
  def handle_info({:page_change, page}, %{assigns: assigns} = socket) do
    result =
      Conferences.paginate_conferences(
        assigns.current_user.id,
        assigns.query,
        page,
        assigns.per_page
      )

    {:noreply,
     socket
     |> assign_conferences(result)
     |> update_params(result)}
  end

  @impl true
  def handle_event(
        "filter",
        %{"per_page" => per_page, "query" => query},
        %{assigns: assigns} = socket
      ) do
    result =
      Conferences.paginate_conferences(assigns.current_user.id, query, assigns.page, per_page)

    {:noreply,
     socket
     |> assign_filters(per_page, query)
     |> assign_conferences(result)
     |> update_params(result)}
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end

  defp assign_conferences(socket, result) do
    socket
    |> assign(conferences: result.entries)
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
        Routes.conference_index_path(socket, :conferences,
          page: result.page_number,
          per_page: assigns.per_page,
          query: assigns.query
        )
    )
  end

  defp bool_icon(true), do: "<i class=\"fas fa-check text-success\">"
  defp bool_icon(false), do: "<i class=\"fas fa-times text-danger\">"

  defp translate_conference_type("national"), do: gettext("National")
  defp translate_conference_type("international"), do: gettext("International")
end
