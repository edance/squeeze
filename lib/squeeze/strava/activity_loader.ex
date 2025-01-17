defmodule Squeeze.Strava.ActivityLoader do
  @moduledoc """
  Loads data from strava and updates the activity
  """

  alias Squeeze.Accounts.Credential
  alias Squeeze.Activities
  alias Squeeze.ActivityMatcher
  alias Squeeze.Challenges.ScoreUpdater
  alias Squeeze.Notifications
  alias Squeeze.Repo
  alias Squeeze.Strava.{ActivityFormatter, Client, StreamSetConverter}

  import Squeeze.Utils, only: [cast_float: 1]

  def update_or_create_activity(%Credential{} = credential, strava_activity_id)
      when is_binary(strava_activity_id) or is_integer(strava_activity_id) do
    case fetch_strava_activity(credential, strava_activity_id) do
      {:ok, strava_activity} ->
        update_or_create_activity(credential, strava_activity)

      {:error, %{status: 404}} ->
        {:error, :not_found}
    end
  end

  def update_or_create_activity(%Credential{} = credential, strava_activity) do
    credential = Repo.preload(credential, user: :user_prefs)
    user = credential.user
    activity = ActivityFormatter.format(strava_activity)

    case ActivityMatcher.get_closest_activity(user, activity) do
      nil ->
        with {:ok, activity} <- Activities.create_activity(user, activity),
             {:ok, _} <- save_laps(activity, strava_activity.laps),
             {:ok, _} <- save_trackpoints(credential, activity) do
          Notifications.notify_new_activity(activity)
          ScoreUpdater.update_score(activity)
          {:ok, activity}
        end

      existing_activity ->
        with {:ok, activity} <- Activities.update_activity(existing_activity, activity),
             {:ok, _} <- save_laps(activity, strava_activity.laps),
             {:ok, _} <- save_trackpoints(credential, activity) do
          {:ok, activity}
        end
    end
  end

  defp fetch_strava_activity(%Credential{} = credential, activity_id) do
    credential
    |> Client.new()
    |> activities_module().get_activity_by_id(activity_id)
  end

  defp save_trackpoints(credential, %{external_id: strava_activity_id} = activity) do
    with {:ok, stream_set} <- fetch_streams(strava_activity_id, credential),
         trackpoints = StreamSetConverter.convert_stream_set_to_trackpoints(stream_set),
         {:ok, trackpoint_set} <- Activities.create_trackpoint_set(activity, trackpoints),
         {:ok, _} <- Activities.create_trackpoint_sections(trackpoint_set) do
      {:ok, trackpoint_set}
    else
      # Manually created activities do not have streams
      {:error, %{status: 404}} -> {:ok, []}
      error -> error
    end
  end

  defp save_laps(_, nil), do: {:ok, 0}

  defp save_laps(activity, laps) do
    laps = Enum.map(laps, &format_lap(activity, &1))
    Activities.create_laps(activity, laps)
  end

  defp format_lap(activity, lap) do
    %{
      average_cadence: cast_float(lap.average_cadence),
      average_speed: cast_float(lap.average_speed),
      distance: cast_float(lap.distance),
      elapsed_time: lap.elapsed_time,
      start_index: lap.start_index,
      end_index: lap.end_index,
      lap_index: lap.lap_index,
      max_speed: cast_float(lap.max_speed),
      moving_time: lap.moving_time,
      name: lap.name,
      pace_zone: lap.pace_zone,
      split: lap.split,
      start_date: Timex.to_naive_datetime(lap.start_date) |> NaiveDateTime.truncate(:second),
      start_date_local:
        Timex.to_naive_datetime(lap.start_date_local) |> NaiveDateTime.truncate(:second),
      total_elevation_gain: cast_float(lap.total_elevation_gain),
      activity_id: activity.id
    }
  end

  defp activities_module do
    Application.get_env(:squeeze, :strava_activities, Strava.Activities)
  end

  defp streams_module do
    Application.get_env(:squeeze, :strava_streams, Strava.Streams)
  end

  defp fetch_streams(id, credential) do
    client = Client.new(credential)
    streams = StreamSetConverter.streams() |> Enum.join(",")
    streams_module().get_activity_streams(client, id, streams, true)
  end
end
