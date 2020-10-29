defmodule UniWeb.AuthenticationController do
  use UniWeb, :controller

  alias Uni.Users
  alias Uni.Users.User

  def login(conn, %{"user" => params}) do
    case Uni.Users.get_by_email(params["email"]) do
      %Uni.Users.User{} = user ->
        if Bcrypt.verify_pass(params["password"], user.password),
          do: successful_login(conn, user),
          else: wrong_credentials(conn)

      nil ->
        wrong_credentials(conn)
    end
  end

  def login(conn, _params), do: wrong_credentials(conn)

  def logout(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> redirect(to: "/")
  end

  def login_page(conn, _params) do
    render(conn, "login.html", changeset: Users.change_user(%User{}))
  end

  defp successful_login(conn, user) do
    conn
    |> put_session(:user_id, user.id)
    |> redirect(to: "/")
  end

  defp wrong_credentials(conn) do
    conn
    |> put_flash(:error, gettext("Email and password do not match"))
    |> redirect(to: "/login")
  end
end
