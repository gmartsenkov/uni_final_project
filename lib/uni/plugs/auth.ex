defmodule Uni.Plugs.Auth do
  use UniWeb, :controller

  def init(opts), do: opts

  def call(conn, _config \\ []) do
    conn
    |> get_session(:user_id)
    |> next(conn)
  end

  def next(nil, conn) do
    conn
    |> put_flash(:error, gettext("Please log in"))
    |> redirect(to: "/login")
    |> halt()
  end

  def next(_user_id, conn), do: conn
end
