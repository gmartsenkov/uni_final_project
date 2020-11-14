defmodule UniWeb.UserLive.Profile do
  use UniWeb, :live_view
  alias Uni.Users
  alias Uni.Faculties

  @allowed_params ["email", "name", "faculty_id", "department_id"]

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)

    {:ok,
     socket
     |> assign(:page_title, "#{gettext("Profile")} - #{socket.assigns.current_user.name}")
     |> assign(:profile_changeset, Users.change_user(socket.assigns.current_user))
     |> assign(:email_form_error, nil)
     |> assign(:faculties, faculties())
     |> assign(:faculty_id, socket.assigns.current_user.faculty_id)
     |> assign(:tab, "profile")}
  end

  @impl true
  def handle_event("change_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :tab, tab)}
  end

  @impl true
  def handle_event("profile_on_change", %{"user" => %{"faculty_id" => faculty_id}}, socket) do
    {:noreply,
     socket
     |> assign(:faculty_id, faculty_id)}
  end

  @impl true
  def handle_event("save_profile", %{"user" => params}, socket) do
    case Users.update_user(socket.assigns.current_user, Map.take(params, @allowed_params)) do
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
        %{"change_password" => %{"password" => password, "new_password" => new_password}},
        socket
      ) do
    current_user = socket.assigns.current_user

    if Bcrypt.verify_pass(password, current_user.password) do
      hashed_password = Bcrypt.hash_pwd_salt(new_password)

      case Users.update_user(current_user, %{"password" => hashed_password}) do
        {:ok, user} ->
          {:noreply,
           socket
           |> assign(:current_user, user)
           |> assign(:email_form_error, nil)
           |> push_redirect(to: Routes.user_profile_path(socket, :my_profile))
           |> put_flash(:info, gettext("Password updated successfully"))}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :profile_changeset, changeset)}
      end
    else
      {:noreply,
       socket
       |> assign(:email_form_error, gettext("The password is wrong"))}
    end
  end

  defp faculties() do
    Faculties.faculties()
    |> Enum.map(fn f -> {f.name, f.id} end)
  end

  defp departments(faculty_id) do
    Faculties.departments(%{id: faculty_id})
    |> Enum.map(fn f -> {f.name, f.id} end)
  end

  defp active?(tab, expected) when tab == expected, do: "active"
  defp active?(_tab, _expected), do: ""
end
