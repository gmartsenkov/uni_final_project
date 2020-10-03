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

  def handle_event(
        "change_email",
        %{"user" => %{"new_email" => new_email, "password" => password}},
        socket
      ) do
    if Bcrypt.verify_pass(password, socket.assigns.current_user.password) do
      update_email(new_email, socket)
    else
      {:noreply, assign(socket, :email_form_error, gettext("Password is incorrect"))}
    end
  end

  defp update_email(new_email, socket) do
    case Users.update_user(socket.assigns.current_user, %{"email" => new_email}) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(:current_user, user)
         |> assign(:email_form_error, nil)
         |> put_flash(:info, gettext("Email updated successfully"))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :email_form_error, Errors.full_messages(changeset))}
    end
  end

  defp active?(tab, expected) when tab == expected, do: "active"
  defp active?(_tab, _expected), do: ""
end
