defmodule UniWeb.Emails.PasswordReset do
  import Bamboo.Email

  alias UniWeb.Router.Helpers, as: Routes

  def call(user, socket) do
    new_email(
      to: user.email,
      from: "support@swu-project.herokuapp.com",
      subject: "Възстановяване на парола",
      html_body: body(user, socket)
    )
  end

  defp body(user, socket) do
    """
      <strong>Възстановяване на парола</strong>
      <br><br>
      Последвайте
      <a href="#{Routes.authentication_reset_pass_url(socket, :reset_pass, %{token: jwt_token(user)})}">линка</a> за да създадете нова парола. (важи за 30 минути)
    """
  end

  defp jwt_token(user) do
    UniWeb.Token.generate(user)
  end
end
