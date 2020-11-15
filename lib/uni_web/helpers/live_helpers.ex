defmodule UniWeb.Helpers.LiveHelpers do
  import Phoenix.LiveView

  def assign_defaults(socket, session) do
    socket
    |> assign_current_user(session)
    |> assign_navigation()
  end

  def protected(socket, role, callback) do
    if Map.get(socket.assigns.current_user, role) == true do
      callback.(socket)
    else
      {:ok, push_redirect(socket, to: "/")}
    end
  end

  defp assign_current_user(socket, %{"user_id" => user_id}) do
    assign_new(
      socket,
      :current_user,
      fn -> Uni.Users.get_user(user_id) end
    )
    |> assign(:logged_in, true)
  end

  defp assign_current_user(socket, _session) do
    assign(socket, :logged_in, false)
  end

  defp assign_navigation(%{assigns: %{logged_in: false}} = socket), do: socket

  defp assign_navigation(%{assigns: %{logged_in: true}} = socket) do
    socket
    |> assign(:navigation, %{action: socket.assigns.live_action})
    |> assign(:current_user, socket.assigns.current_user)
  end
end
