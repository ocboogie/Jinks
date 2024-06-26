defmodule Jinks.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      JinksWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:jinks, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Jinks.PubSub},
      Jinks.RoomManager,

      # Start a worker by calling: Jinks.Worker.start_link(arg)
      # {Jinks.Worker, arg},
      # Start to serve requests, typically the last entry
      JinksWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Jinks.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    JinksWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
