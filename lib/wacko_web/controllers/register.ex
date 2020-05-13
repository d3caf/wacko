defmodule WackoWeb.RegisterController do
  use WackoWeb, :controller
  import Phoenix.LiveView.Controller

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
        add_player(conn, player, table_name)

      {_, path} ->
        redirect(conn, to: path)
    end
  end

  defp add_player(conn, player, table_name) do
    case Racko.GameServer.add_player(table_name, player) do
      {:error, message} ->
        put_flash(conn, :error, message)
        |> redirect(to: "/")

      :ok ->
        redirect(conn,
          to: WackoWeb.Router.Helpers.live_path(conn, WackoWeb.TablesLive.Lobby, table_name)
        )
    end
  end
end
