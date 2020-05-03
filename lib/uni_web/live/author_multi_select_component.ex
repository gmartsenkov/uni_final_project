defmodule UniWeb.AuthorMultiSelectComponent do
  use UniWeb, :live_component

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:error, nil)
      |> assign_new(:selected, fn -> [] end)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div>
    <label>Author</label>
    <div class="input-group">
      <input
        type="text"
        autocomplete="off"
        class="form-control"
        value="<%= @author_search %>"
        list="authors"
        name="author_search">
     <div class="input-group-append">
        <button
          phx-target="<%= @myself %>"
          phx-click="add-author"
          class="btn btn-outline-secondary"
          type="button"
          id="button-addon2">
            Add
        </button>
      </div>
    </div>
      <%= if @error do %>
        <div class="invalid-feedback mt-1 mb-0">
          <%= @error %>
        </div>
      <% end %>
    <datalist id="authors">
      <%= for author <- @authors do %>
        <option value="<%= author %>"><%= author %></option>
      <% end %>
    </datalist>
    <ul class="list-group mt-1">
      <%= for author <- @selected do %>
        <li class="list-group-item" id="<%= author %>">
          <i class="fas fa-user-graduate"></i>
          <%= author%>
          <a
            href="#"
            class="float-right"
            phx-target="<%= @myself %>"
            phx-value-author="<%= author %>"
            phx-click="remove-author">
            <i class="far fa-times-circle"></i>
          <a/>
        </li>
      <% end %>
    </ul>
    </div>
    """
  end

  @impl true
  def handle_event("add-author", _data, %{assigns: assigns} = socket) do
    found = Enum.find(assigns.authors, nil, &(&1 == assigns.author_search))

    case found do
      nil ->
        {:noreply, assign(socket, :error, "User does not exist")}

      author ->
        {:noreply,
         socket
         |> assign(:selected, assigns.selected ++ [author])
         |> assign(:author_search, "")}
    end
  end

  @impl true
  def handle_event("remove-author", %{"author" => author}, %{assigns: assigns} = socket) do
    found = Enum.find(assigns.selected, nil, &(&1 == author))

    case found do
      nil ->
        {:noreply, assign(socket, :error, "User does not exist")}

      author ->
        {:noreply,
         socket
         |> assign(:selected, Enum.reject(assigns.selected, &(&1 == author)))
         |> assign(:author_search, "")}
    end
  end
end
