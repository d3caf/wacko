defmodule WackoWeb.TablesLive.Game do
  use Phoenix.LiveView

  alias Phoenix.PubSub
  alias Racko.{Player, GameServer, Game}

  @impl true
  def mount(%{"table_name" => game_name}, %{"current_player" => player}, socket) do
    Phoenix.PubSub.subscribe(Wacko.PubSub, "table:#{game_name}")

    {:ok,
     socket
     |> assign(
       player_name: player.name,
       game: GameServer.get_game(game_name),
       game_name: game_name
     )}
  end

  @impl true
  def render(assigns), do: WackoWeb.TablesView.render("game.html", assigns)

  # --- Events
  #  @impl true

  @impl true
  def handle_event("draw_from_deck", _value, socket) do
    game = GameServer.draw_from_deck(game_name(socket), get_player(socket))
    {:noreply, assign(socket, :game, game)}
  end

  def handle_event("draw_revealed", _value, socket) do
    game = GameServer.draw_revealed_card(game_name(socket), get_player(socket))
    {:noreply, assign(socket, :game, game)}
  end

  @impl true
  def handle_event("insert", %{"index" => index}, socket) do
    # TODO refactor
    game =
      GameServer.put_hand_in_rack(game_name(socket), get_player(socket), String.to_integer(index))

    if !is_nil(game.winner) && Map.get(game.winner, :name) == get_player(socket).name do
      {:noreply, assign(socket, :game, game)}
    else
      game = GameServer.end_turn(game_name(socket))

      broadcast_update(socket, {:game_update, game})
      {:noreply, assign(socket, :game, game)}
    end
  end

  @impl true
  def handle_event("wacko", _value, %{assigns: %{game: %{winner: winner}}} = socket) do
    broadcast_update(socket, {:wacko, winner})
    {:noreply, socket}
  end

  # /--- Broadcasts
  @impl true
  def handle_info({:game_update, game}, socket) do
    {:noreply, socket |> assign(:game, game)}
  end

  @impl true
  def handle_info({:wacko, winner}, socket) do
    {:noreply, socket |> fetch_game}
  end

  # --\

  defp game_name(%{assigns: %{game_name: game_name}}) do
    game_name
  end

  defp broadcast_update(%{assigns: %{game_name: game_name}}, msg) do
    PubSub.broadcast_from!(Wacko.PubSub, self(), "table:#{game_name}", msg)
  end

  defp fetch_game(%{assigns: %{game_name: game_name}} = socket) do
    socket |> assign(:game, Racko.GameServer.get_game(game_name))
  end

  defp get_player(%{assigns: %{game: %{players: players}, player_name: name}}) do
    Map.get(players, name)
  end

  defp end_turn(socket, game) do
    broadcast_update(socket, {:game_update, game})
    {:noreply, assign(socket, :game, game)}
  end
end
