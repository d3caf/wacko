defmodule WackoWeb.TablesView do
  use WackoWeb, :view

  alias WackoWeb.TablesLive
  alias Racko.{Player, Game}

  def all_ready?(players) do
    Enum.all?(players, fn {_name, %{metas: [%{ready: ready} | _]}} -> ready end)
  end

  def get_turn(%Game{active_player: active_player}), do: active_player

  def my_turn?(%Game{active_player: active_player}, name) do
    if name == active_player, do: true, else: false
  end

  def winner?(%Game{winner: %Player{name: name}}), do: name
  def winner?(%Game{winner: nil}), do: false

  def get_revealed(%Game{revealed: revealed}), do: revealed |> List.first()

  def get_rack(game, name) do
    # TODO refactor
    get_player(game, name)
    |> Map.get(:rack)
    |> Enum.zip(get_scale(game))
    |> Enum.with_index()
    |> Enum.reverse()
  end

  def get_scale(%Game{players: players}) do
    case Enum.count(players) do
      2 -> 4..40
      3 -> 5..50
      4 -> 6..60
      _ -> 2..30
    end
    |> Enum.to_list()
    |> Enum.take_every(Enum.count(players) + 2)
  end

  def get_hand(game, name) do
    game
    |> get_player(name)
    |> Map.get(:hand)
  end

  def get_player(%Game{players: players}, name) do
    Map.get(players, name)
  end

  def hand_empty?(game, name) do
    get_player(game, name)
    |> Map.get(:hand)
    |> is_nil
  end
end
