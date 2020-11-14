defmodule UniWeb.UserLive.Index do
  use UniWeb, :live_view

  alias Uni.Users

  @filters ["per_page", "query"]

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)

    protected(socket, :admin, fn socket ->
      {:ok,
       socket
       |> assign(:query, "")
       |> assign(:per_page, 10)
       |> assign(:page_title, gettext("Users"))}
    end)
  end

  @impl true
  def handle_params(params, _uri, socket) do
    query = Map.get(params, "query", "")
    page = Map.get(params, "page", "1")
    per_page = Map.get(params, "per_page", "10")

    result = Users.paginate(query, page, per_page)

    {:noreply,
     socket
     |> assign(:users, result.entries)
     |> assign(:page, result.page_number)
     |> assign(:total_pages, result.total_pages)
     |> assign(:per_page, per_page)
     |> assign(:query, query)
     |> assign(:total, result.total_entries)}
  end

  @impl true
  def handle_event("filter", params, socket) do
    params = Map.take(params, @filters)
    {:noreply, push_patch(socket, to: Routes.user_index_path(socket, :users, params))}
  end

  @impl true
  def handle_info({:page_change, page}, socket) do
    params = %{
      "page" => page,
      "query" => socket.assigns.query,
      "per_page" => socket.assigns.per_page
    }

    {:noreply,
     socket
     |> push_patch(to: Routes.user_index_path(socket, :users, params))}
  end
end
