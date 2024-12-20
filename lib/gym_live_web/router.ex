defmodule GymLiveWeb.Router do
  use GymLiveWeb, :router

  import GymLiveWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GymLiveWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Development routes
  if Application.compile_env(:gym_live, :dev_routes) do
    # Enable LiveDashboard and Swoosh mailbox preview in development
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GymLiveWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/", GymLiveWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/", PageController, :home

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{GymLiveWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", Live.Auth.UserRegistration, :new
      live "/users/log_in", Live.Auth.UserLogin, :new
      live "/users/reset_password", Live.Auth.UserForgotPassword, :new
      live "/users/reset_password/:token", Live.Auth.UserResetPassword, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", GymLiveWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [
        {GymLiveWeb.UserAuth, :ensure_authenticated},
        GymLiveWeb.Live.Components.Layout.Nav
      ] do
      live "/users/settings", Live.Auth.UserSettings, :edit
      live "/users/settings/confirm_email/:token", Live.Auth.UserSettings, :confirm_email

      live "/workout/:id", Live.Workouts.ViewWorkout
      live "/workouts", Live.Workouts.ViewWorkouts
      live "/edit_workout", Live.Workouts.EditWorkout

      live "/charts", Live.Charts.ViewCharts
    end
  end

  scope "/", GymLiveWeb do
    pipe_through [:browser]

    get "/frames/last-workout/:userid", FrameController, :last_workout
    get "/workouts/:id/image", WorkoutImageController, :show
    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{GymLiveWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", Live.Auth.UserConfirmation, :edit
      live "/users/confirm", Live.Auth.UserConfirmationInstructions, :new
    end
  end
end
