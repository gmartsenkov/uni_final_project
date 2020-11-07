defmodule UniWeb.UserLive.FormComponent do
  use UniWeb, :live_component

  alias Uni.Users
  alias Uni.Faculties

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset = Users.change_user(user)

    {:ok,
     socket
     |> assign(:changeset, changeset)
     |> assign(:faculties, faculties())
     |> assign(:faculty_id, user.faculty_id)
     |> assign(assigns)}
  end

  @impl true
  def handle_event("profile_on_change", %{"user" => %{"faculty_id" => faculty_id} = params}, socket) do
    {:noreply,
     socket
     |> assign(:changeset, Users.change_user(socket.assigns.user, params))
     |> assign(:faculty_id, faculty_id)}
  end

  def handle_event("update", %{"user" => params}, socket) do
    password = Map.get(params, "password", "")

    params =
      if password == "" do
        Map.delete(params, "password")
      else
        Map.put(params, "password", Bcrypt.hash_pwd_salt(password))
      end

    case Users.update_user(socket.assigns.user, params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(:user, user)
         |> push_redirect(to: Routes.user_edit_path(socket, :users, user))
         |> put_flash(:info, gettext("User updated successfully"))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("new", %{"user" => params}, socket) do
    password = Map.get(params, "password", "")
    params = Map.put(params, "password", Bcrypt.hash_pwd_salt(password))

    case Users.create_user(params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> push_redirect(to: Routes.user_edit_path(socket, :users, user))
         |> put_flash(:info, gettext("User created successfully"))}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp faculties() do
    Faculties.faculties()
    |> Enum.map(fn f -> {f.name, f.id} end)
  end

  defp departments(nil) do
    Faculties.faculties()
    |> List.first()
    |> Map.get(:id)
    |> departments()
  end

  defp departments(faculty_id) do
    Faculties.departments(%{id: faculty_id})
    |> Enum.map(fn f -> {f.name, f.id} end)
  end
end
