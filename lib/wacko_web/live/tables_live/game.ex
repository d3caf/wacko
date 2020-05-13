defmodule WackoWeb.TablesLive.Game do
  use Phoenix.LiveView

  alias Racko.{Player, GameServer}

  @impl true
  def mount(%{"table_name" => game_name}, %{"current_player" => player}, socket) do
    IO.inspect(GameServer.get_game(game_name))

    {:ok,
     socket
     |> assign(
       player: GameServer.get_player(game_name, player.name),
       game: GameServer.get_game(game_name)
     )}
  end

  @impl true
  def render(assigns), do: WackoWeb.TablesView.render("game.html", assigns)
end
