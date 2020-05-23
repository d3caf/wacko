defmodule WackoWeb.RegisterController do
  use WackoWeb, :controller
  import Phoenix.LiveView.Controller

  alias WackoWeb.Router.Helpers, as: Routes

  def register(conn, _params) do
    render(conn, "register.html")
  end

  def submit(conn, %{
        "player" => %{"name" => name, "color" => color}
      }) do
    player = Racko.Player.new(name, color)

    conn
    |> put_session(:current_player, player)
    |> navigate(player)
  end

  defp navigate(conn, player) do
    case get_session(conn, :return_to) do
      {:table, table_name} ->
        redirect(conn,
          to: Routes.live_path(conn, WackoWeb.TablesLive.Lobby, table_name)
        )

      {_, path} ->
        redirect(conn, to: path)
    end
  end
end
