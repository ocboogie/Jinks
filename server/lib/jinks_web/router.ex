defmodule JinksWeb.Router do
  use JinksWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", JinksWeb do
    pipe_through :api
  end
end
