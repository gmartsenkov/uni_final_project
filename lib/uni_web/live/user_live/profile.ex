defmodule UniWeb.UserLive.Profile do
  use UniWeb, :live_view
  alias Uni.Users
  alias UniWeb.Helpers.Errors

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)

    {:ok,
     socket
     |> assign(:page_title, "#{gettext("Profile")} - #{socket.assigns.current_user.name}")
     |> assign(:profile_changeset, Users.change_user(socket.assigns.current_user))
     |> assign(:email_form_error, nil)
     |> assign(:tab, "profile")}
  end

  @impl true
  def handle_event("change_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :tab, tab)}
  end

  @impl true
  def handle_event("save_profile", %{"user" => %{"name" => name}}, socket) do
    case Users.update_user(socket.assigns.current_user, %{"name" => name}) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(:current_user, user)
         |> push_redirect(to: Routes.user_profile_path(socket, :my_profile))
         |> put_flash(:info, gettext("Profile updated successfully"))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :profile_changeset, changeset)}
    end
  end

  @impl true
  def handle_event(
        "update_password",
        %{"password" => password, "new_password" => new_password},
        socket
      ) do
    current_user = socket.assigns.current_user

    if Bcrypt.verify_pass(password, current_user.password) do
      {:noreply,
       socket
       |> assign(:email_from_error, nil)}
    else
      {:noreply,
       socket
       |> assign(:email_form_error, gettext("Current password is not correct"))}
    end
  end

  defp active?(tab, expected) when tab == expected, do: "active"
  defp active?(_tab, _expected), do: ""
end
