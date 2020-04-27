defmodule UniWeb.AuthenticationController do
  use UniWeb, :controller

  def login(conn, %{ "user" => params}) do
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

  defp successful_login(conn, user) do
    conn
    |> put_session(:user_id, user.id)
    |> redirect(to: "/")
  end

  defp wrong_credentials(conn) do
    conn
    |> put_flash(:error, "User and pass dont match")
    |> redirect(to: "/login")
  end
end
