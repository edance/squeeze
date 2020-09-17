defmodule Squeeze.Challenges.Challenge do
  @moduledoc """
  This module is the schema for challenges in the database.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.{User}
  alias Squeeze.Challenges.{Score}

  @required_fields ~w(
    activity_type
    challenge_type
    timeline
  )a
  @optional_fields ~w(
    name
    start_at
    end_at
  )a

  schema "challenges" do
    field :activity_type, ActivityTypeEnum
    field :challenge_type, ChallengeTypeEnum
    field :end_at, :naive_datetime
    field :name, :string
    field :start_at, :naive_datetime
    field :timeline, TimelineEnum

    belongs_to :user, User
    has_many :scores, Score
    many_to_many :users, User, join_through: "scores", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(challenge, attrs) do
    challenge
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def add_user_changeset(challenge, %User{} = user) do
    challenge
    |> put_assoc(:users, [user])
  end
end