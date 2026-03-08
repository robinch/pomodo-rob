defmodule PomodoRob.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PomodoRobWeb.Telemetry,
      PomodoRob.Repo,
      {DNSCluster, query: Application.get_env(:pomodo_rob, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PomodoRob.PubSub},
      # Start a worker by calling: PomodoRob.Worker.start_link(arg)
      # {PomodoRob.Worker, arg},
      # Start to serve requests, typically the last entry
      PomodoRobWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PomodoRob.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PomodoRobWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
