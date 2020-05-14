defmodule WackoWeb.TablesLive.Lobby do
  use Phoenix.LiveView

  alias WackoWeb.Presence
  alias Phoenix.{Socket.Broadcast, PubSub}

  alias Racko.{GameServer, Player, Game}
  alias WackoWeb.Router.Helpers, as: Routes

  @impl true
  def mount(
        %{"table_name" => table_name},
        %{"current_player" => %Player{name: name}},
        socket
      ) do
    PubSub.subscribe(Wacko.PubSub, "table:#{table_name}")
    Presence.track(self(), "table:#{table_name}", name, %{ready: false})

    {:ok,
     socket
     |> assign(table_name: table_name, player: name)
     |> fetch}
  end

  @impl true
  def render(assigns), do: WackoWeb.TablesView.render("lobby.html", assigns)

  @impl true
  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    {:noreply, fetch(socket)}
  end

  @impl true
  def handle_info(:start_game, socket) do
    {:noreply,
     push_redirect(socket,
       to: Routes.live_path(socket, WackoWeb.TablesLive.Game, get_table(socket))
     )}
  end

  @impl true
  def handle_event("ready", _value, %{assigns: %{player: player}} = socket) do
    %{metas: [%{ready: ready} | _]} = Presence.get_by_key("table:#{get_table(socket)}", player)

    Presence.update(self(), "table:#{get_table(socket)}", player, %{
      ready: !ready
    })

    {:noreply, socket}
  end

  def handle_event("start", _value, socket) do
    GameServer.start_game(get_table(socket))

    PubSub.broadcast_from!(Wacko.PubSub, self(), "table:#{get_table(socket)}", :start_game)

    {:noreply,
     push_redirect(socket,
       to: Routes.live_path(socket, WackoWeb.TablesLive.Game, get_table(socket))
     )}
  end

  defp fetch(socket) do
    socket
    |> assign(%{online_players: Presence.list("table:#{get_table(socket)}")})
  end

  defp get_table(socket) do
    socket.assigns.table_name
  end
end
