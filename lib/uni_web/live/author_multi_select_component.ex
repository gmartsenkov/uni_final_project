defmodule UniWeb.AuthorMultiSelectComponent do
  use UniWeb, :live_component

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:error, nil)
      |> assign_new(:authors, fn -> [] end)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div
      id="author-multiselect"
      phx-target="<%= @myself %>"
      phx-hook="AuthorAutocomplete"

      phx-update="ignore">
      <label>Author</label>
      <div class="input-group">
          <select class="form-control" id="autocompleteAuthor" style="width: 100%"></select>
      </div>
    </div>
    <%= if @error do %>
      <div class="invalid-feedback mt-1 mb-0">
        <%= @error %>
      </div>
    <% end %>
    <ul class="list-group mt-1">
      <%= for author <- @authors do %>
        <li class="list-group-item" id="author-<%= author["id"] %>">
          <input type="text" style="display: none" name="authors[]" value="<%= author["id"] %>">
          <i class="fas fa-user-graduate"></i>
            <%= author["text"] %>
          <a
            href="#"
            id="remove-author-<%= author["id"] %>"
            class="float-right"
            phx-target="<%= @myself %>"
            phx-value-author="<%= author["id"] %>"
            phx-click="remove_author">
            <i class="far fa-times-circle"></i>
          <a/>
        </li>
      <% end %>
    </ul>
    </div>
    """
  end

  @impl true
  def handle_event("add_author", author, %{assigns: assigns} = socket) do
    {:noreply,
     socket
     |> assign(:authors, assigns.authors ++ [author])}
  end

  @impl true
  def handle_event("remove_author", %{"author" => author_id}, %{assigns: assigns} = socket) do
    found = Enum.find(assigns.authors, nil, &(&1["id"] == String.to_integer(author_id)))

    case found do
      nil ->
        {:noreply, assign(socket, :error, "User does not exist")}

      author ->
        {:noreply,
         socket
         |> assign(:authors, Enum.reject(assigns.authors, &(&1["id"] == author["id"])))}
    end
  end
end
