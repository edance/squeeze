defmodule SqueezeWeb.Settings.UserFormComponent do
  use SqueezeWeb, :live_component

  def time_zones do
    Tzdata.zone_list()
    |> Enum.map(fn(x) ->
      {String.replace(x, "_", " "), x}
    end)
  end
end