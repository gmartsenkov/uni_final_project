defmodule UniWeb.PaginationComponent do
  use UniWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> update_navigation()}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <nav class="float-right">
      <ul class="pagination">
        <li class="page-item <%= unless @prev, do: "disabled"%>">
          <a class="page-link shadow-none"
            href="#" tabindex="-1"
            phx-target="<%= @myself %>"
            phx-click="prev_page"
            aria-disabled="true">
            <%= gettext("Previous") %>
          </a>
        </li>        
        <%= for page <- @page_range do %>
          <li class="page-item <%= if page == @page, do: "active" %>">
            <a
              class="page-link shadow-none"
              href="#"
              phx-click="change_page"
              phx-value-page="<%= page %>"
              phx-target="<%= @myself %>">
              <%= page %>
            </a>
          </li>
        <% end %>
        <li class="page-item <%= if @next, do: "disabled"%>">
          <a phx-target="<%= @myself %>"
            phx-click="next_page"
            class="page-link shadow-none"
            href="#">
            <%= gettext("Next") %>
          </a>
        </li>
      </ul>
    </nav>
    """
  end

  @impl true
  def handle_event("change_page", %{"page" => page}, socket) do
    send_page_change(String.to_integer(page))

    {:noreply,
     socket
     |> assign(:page, String.to_integer(page))
     |> update_navigation()}
  end

  def handle_event("next_page", _params, socket) do
    send_page_change(socket.assigns.page + 1)

    {:noreply,
     socket
     |> assign(:page, socket.assigns.page + 1)
     |> update_navigation()}
  end

  def handle_event("prev_page", _params, socket) do
    send_page_change(socket.assigns.page - 1)

    {:noreply,
     socket
     |> assign(:page, socket.assigns.page - 1)
     |> update_navigation()}
  end

  def update_navigation(%{assigns: assigns} = socket) do
    socket
    |> assign(:page_range, page_range(assigns.page, assigns.total_pages))
    |> assign(:next, assigns.page == assigns.total_pages)
    |> assign(:prev, assigns.page != 1)
  end

  defp send_page_change(page), do: send(self(), {:page_change, page})

  defp page_range(_page, total_pages) when total_pages <= 3, do: 1..total_pages
  defp page_range(page, _total_pages) when page == 1, do: 1..3
  defp page_range(page, total_pages) when page == total_pages, do: (total_pages - 2)..total_pages
  defp page_range(page, _total_pages), do: [page - 1, page, page + 1]
end
