defmodule Filters do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :query
    field :per_page
    field :admin
    field :head_faculty
    field :head_department
  end

  def changeset(attrs) do
    cast(%Filters{}, attrs, [
      :query,
      :per_page,
      :admin,
      :head_faculty,
      :head_department
    ])
  end
end

defmodule UniWeb.UserLive.Index do
  use UniWeb, :live_view

  alias Uni.Users
  alias Uni.Users.User

  @filters ["per_page", "query", "admin", "head_department", "head_faculty"]

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)

    protected(socket, :admin, fn socket ->
      {:ok,
       socket
       |> assign(:filters, Filters.changeset(%{query: "", per_page: 10}))
       |> assign(:query, "")
       |> assign(:per_page, 10)
       |> assign(:page_title, gettext("Users"))}
    end)
  end

  @impl true
  def handle_params(params, _uri, socket) do
    page = Map.get(params, "page", "1")
    per_page = Map.get(params, "per_page", "10")
    query = Map.get(params, "query", "")

    result =
      User
      |> Users.filter(Map.to_list(params))
      |> Users.paginate(page, per_page)

    {:noreply,
     socket
     |> assign(:users, result.entries)
     |> assign(:filters, Filters.changeset(params))
     |> assign(:page, result.page_number)
     |> assign(:query, query)
     |> assign(:total_pages, result.total_pages)
     |> assign(:per_page, per_page)
     |> assign(:total, result.total_entries)}
  end

  @impl true
  def handle_event("filter", %{"filters" => params}, socket) do
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

  defp per_page do
    [
      {"10", "10"},
      {"25", "25"},
      {"50", "50"}
    ]
  end
end
