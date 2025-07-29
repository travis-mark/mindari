defmodule MindariWeb.Router do
  use MindariWeb, :router

  import MindariWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MindariWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MindariWeb do
    pipe_through :browser

    get "/", HomeController, :index
  end

  scope "/", MindariWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/onthisday", OnThisDayController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", MindariWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:mindari, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MindariWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", MindariWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{MindariWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", MindariWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{MindariWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/login", UserLive.Login, :new
      live "/login/:token", UserLive.Confirmation, :new

      live "/counter", CounterLive.Index, :index
      live "/counter/new", CounterLive.Form, :new
      live "/counter/:id", CounterLive.Show, :show
      live "/counter/:id/edit", CounterLive.Form, :edit
    end

    post "/login", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
