defmodule WackoWeb.TablesView do
  use WackoWeb, :view

  alias WackoWeb.TablesLive

  def all_ready?(players) do
    Enum.all?(players, fn {_name, %{metas: [%{ready: ready} | _]}} -> ready end)
  end

  def my_turn?(%{name: name}, %Racko.Game{active_player: active_player}) do
    if name == active_player, do: true, else: false
  end

  def get_rack(game, player) do
    get_player(game, player)
    |> Map.get(:rack)
  end

  def get_player(%{players: players}, %{name: name}) do
    Map.get(players, name)
  end

  def hand_empty?(game, player) do
    get_player(game, player)
    |> Map.get(:hand)
    |> is_nil
  end
end
