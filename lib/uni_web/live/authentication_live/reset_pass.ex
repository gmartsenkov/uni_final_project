defmodule ResetPassForm do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :password
    field :repeat_password
  end

  def changeset(attrs) do
    cast(%ResetPassForm{}, attrs, [
      :password,
      :repeat_password
    ])
  end
end

defmodule UniWeb.AuthenticationLive.ResetPass do
  use UniWeb, :live_view

  alias Uni.Users

  @impl true
  def mount(params, session, socket) do
    socket = assign_defaults(socket, session)

    case UniWeb.Token.verify_and_validate(params["token"]) do
      {:ok, claims} ->
        user = Users.by_id(claims["user_id"])

        if user do
          {
            :ok,
            socket
            |> assign(:user, user)
            |> assign(:form, ResetPassForm.changeset(%{}))
            |> assign(:error, nil)
          }
        else
          invalid(socket)
        end

      _else ->
        invalid(socket)
    end
  end

  @impl true
  def handle_event(
        "save",
        %{"reset_pass_form" => %{"password" => pass}},
        %{assigns: %{user: _user}} = socket
      )
      when byte_size(pass) < 8 do
    {:noreply, assign(socket, :error, gettext("Password needs to be at least 8 characters"))}
  end


  @impl true
  def handle_event(
        "save",
        %{
          "reset_pass_form" =>
            %{"password" => pass, "repeat_password" => repeat_password}
        },
        %{assigns: %{user: user}} = socket
      )
      when pass == repeat_password do
    encrypted = Bcrypt.hash_pwd_salt(pass)

    case Users.update_user(user, %{password: encrypted}) do
      {:ok, _user} ->
        {
          :noreply,
          socket
          |> put_flash(:info, gettext("User password updated"))
          |> redirect(to: Routes.authentication_path(socket, :login_page))
        }
    end
  end

  def handle_event(
        "save",
        %{
          "reset_pass_form" =>
            %{"password" => pass, "repeat_password" => repeat_password}
        },
        %{assigns: %{user: _user}} = socket
      )
      when pass != repeat_password do
    {:noreply, assign(socket, :error, gettext("Passwords don't match"))}
  end

  defp invalid(socket) do
    {
      :ok,
      socket
      |> put_flash(:error, gettext("Link is invalid"))
      |> redirect(to: "/login")
    }
  end
end
