defmodule WackoWeb.TablesView do
  use WackoWeb, :view

  alias WackoWeb.TablesLive

  def all_ready?(players) do
    Enum.all?(players, fn {_name, %{metas: [%{ready: ready} | _]}} -> ready end)
  end

  def output_rack(rack) do
    IO.inspect(rack)
  end

end
