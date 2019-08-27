defmodule Squeeze.Duration do
  @moduledoc """
  This duration module parses and formats strings for a time duration in hours,
  minutes, and seconds.
  """
  @behaviour Ecto.Type

  @match ~r/^(?<hour>\d{1,2}):(?<min>\d{1,2}):?(?<sec>\d{0,2})$/

  def cast(str) when is_binary(str) do
    case Regex.named_captures(@match, str) do
      nil -> :error
      %{"hour" => hour_str, "min" => min_str, "sec" => sec_str} ->
        with {:ok, hours}   <- parse_integer(hour_str),
             {:ok, minutes} <- parse_integer(min_str),
             {:ok, seconds} <- parse_integer(sec_str),
          do: cast_to_secs(hours, minutes, seconds)
    end
  end

  def cast(number) do
    Ecto.Type.cast(:integer, number)
  end

  def dump(number) do
    Ecto.Type.dump(:integer, number)
  end

  def load(number) do
    Ecto.Type.load(:integer, number)
  end

  def type() do
    Ecto.Type.type(:integer)
  end

  defp parse_integer(""), do: {:ok, nil}
  defp parse_integer(str) when is_binary(str) do
    case Integer.parse(str) do
      {value, _} -> {:ok, value}
      :error -> :error
    end
  end

  defp cast_to_secs(minutes, seconds, nil), do: {:ok, (minutes * 60) + seconds}
  defp cast_to_secs(hours, minutes, seconds) do
    {:ok, (hours * 3600) + (minutes * 60) + seconds}
  end
end