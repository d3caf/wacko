defmodule WackoWeb.Router do
  use WackoWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {WackoWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :game do
    plug(:validate_game)
    plug(:require_player)
  end

  scope "/", WackoWeb do
    pipe_through(:browser)

    live("/", PageLive, :index)

    get("/register", RegisterController, :register)
    post("/register", RegisterController, :submit)
  end

  scope "/tables", WackoWeb do
    pipe_through([:browser, :game])

    get("/new", TableController, :new)
    live("/:table_name", TablesLive.Lobby)
    live("/:table_name/play", TablesLive.Game)
  end

  # Other scopes may use custom stacks.
  # scope "/api", WackoWeb do
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
      pipe_through(:browser)
      live_dashboard("/dashboard", metrics: WackoWeb.Telemetry)
    end
  end

  defp require_player(%{request_path: request_path} = conn, _opts) do
    if get_session(conn, :current_player) do
      conn
    else
      conn
      |> put_return_to
      |> redirect(to: WackoWeb.Router.Helpers.register_path(conn, :register))
      |> halt()
    end
  end

  defp validate_game(%{path_params: %{"table_name" => table_name}} = conn, _opts) do
    if Racko.GameServer.valid_game?(table_name) do
      conn
    else
      conn
      |> put_flash(:error, "No game exists called #{table_name}.")
      |> redirect(to: "/")
      |> halt()
    end
  end

  defp validate_game(conn, _opts) do
    conn
  end

  defp put_return_to(%{request_path: request_path} = conn) do
    case request_path do
      "/tables/new" -> conn |> put_session(:return_to, {:new_game, request_path})
      "/tables/" <> table_name -> conn |> put_session(:return_to, {:table, table_name})
      _ -> conn |> put_session(:return_to, {:redirect, request_path})
    end
  end
end
