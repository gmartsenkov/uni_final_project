defmodule UniWeb.AuthenticationLive.ForgottenPass do
  use UniWeb, :live_view

  alias Uni.Users

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)
    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"forgotten_pass" => params}, socket) do
    Users.by_email(params["email"])
    |> send_reset_email(socket)
  end

  def send_reset_email(nil, socket) do
    {
      :noreply,
      socket
      |> put_flash(:error, gettext("User with that email address does not exist."))
      |> redirect(to: "/forgotten_password")
    }
  end

  def send_reset_email(user, socket) do
    UniWeb.Emails.PasswordReset.call(user, socket)
    |> UniWeb.Mailer.deliver_now()

    {
      :noreply,
      socket
      |> put_flash(:info, gettext("Password reset email sent."))
      |> redirect(to: "/login")
    }
  end
end
