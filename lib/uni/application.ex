defmodule Uni.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Uni.Repo,
      # Start the Telemetry supervisor
      UniWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Uni.PubSub},
      # Start the Endpoint (http/https)
      UniWeb.Endpoint
      # Start a worker by calling: Uni.Worker.start_link(arg)
      # {Uni.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Uni.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    UniWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
