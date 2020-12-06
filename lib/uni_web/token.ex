defmodule UniWeb.Token do
  @moduledoc """
  Module to generate an app jwt token.
  """
  use Joken.Config

  def generate(user) do
    extra_claims = %{"user_id" => user.id}

    generate_and_sign!(extra_claims)
  end
end
