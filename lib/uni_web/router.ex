defmodule UniWeb.Router do
  use UniWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {UniWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :protected do
    plug Uni.Plugs.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", UniWeb do
    pipe_through :browser

    live "/register", AuthenticationLive.Register, :register
    post "/login", AuthenticationController, :login
    live "/login", AuthenticationLive.Login, :login
  end

  # Protected routes
  scope "/", UniWeb do
    pipe_through [:browser, :protected]

    live "/", PageLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", UniWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: UniWeb.Telemetry
    end
  end
end
