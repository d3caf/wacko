defmodule WackoWeb.TableController do
  use WackoWeb, :controller

  def new(conn, _params) do
    table_name = Wacko.NameGenerator.generate()

    Racko.GameSupervisor.new_game(table_name, get_session(conn, :current_player))

    conn
    |> redirect(
      to: WackoWeb.Router.Helpers.live_path(conn, WackoWeb.TablesLive.Lobby, table_name)
    )
  end
end
