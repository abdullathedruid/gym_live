defmodule GymLive.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      GymLiveWeb.Telemetry,
      # Start the Ecto repository
      GymLive.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: GymLive.PubSub},
      # Start Finch
      {Finch, name: GymLive.Finch},
      # Start the Endpoint (http/https)
      GymLiveWeb.Endpoint
      # Start a worker by calling: GymLive.Worker.start_link(arg)
      # {GymLive.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GymLive.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GymLiveWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
