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
    get "/login", AuthenticationController, :login_page
  end

  # Protected routes
  scope "/", UniWeb do
    pipe_through [:browser, :protected]

    get "/users/autocomplete", UsersController, :autocomplete
    get "/logout", AuthenticationController, :logout

    get "/exports/articles", ExportsController, :articles

    live "/profile", UserLive.Profile, :my_profile
    live "/users", UserLive.Index, :users
    live "/users/new", UserLive.New, :users
    live "/users/:id", UserLive.Edit, :users

    live "/", ArticleLive.Index, :articles

    live "/articles", ArticleLive.Index, :articles
    live "/articles/new", ArticleLive.New, :articles
    live "/articles/:id", ArticleLive.Edit, :articles

    live "/projects", ProjectLive.Index, :projects
    live "/projects/new", ProjectLive.New, :projects
    live "/projects/:id", ProjectLive.Edit, :projects

    live "/conferences", ConferenceLive.Index, :conferences
    live "/conferences/new", ConferenceLive.New, :conferences
    live "/conferences/:id", ConferenceLive.Edit, :conferences

    live "/monographs", MonographLive.Index, :monographs
    live "/monographs/new", MonographLive.New, :monographs
    live "/monographs/:id", MonographLive.Edit, :monographs

    live "/exports", ExportsLive.Export, :exports
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
