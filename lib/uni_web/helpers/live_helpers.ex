defmodule UniWeb.Helpers.LiveHelpers do
  import Phoenix.LiveView

  def assign_defaults(socket, session) do
    socket
    |> assign_current_user(session)
    |> assign_navigation()
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
    assign(socket, :navigation, %{
      action: socket.assigns.live_action,
      user_name: socket.assigns.current_user.name
    })
  end
end
