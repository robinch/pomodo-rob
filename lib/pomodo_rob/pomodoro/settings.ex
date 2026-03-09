defmodule PomodoRob.Pomodoro.Settings do
  use Ecto.Schema
  import Ecto.Changeset

  schema "settings" do
    field :session_duration, :integer, default: 25
    field :short_break, :integer, default: 5
    field :long_break, :integer, default: 15
    field :sessions_before_long_break, :integer, default: 4

    timestamps(type: :utc_datetime)
  end

  def changeset(settings, attrs) do
    settings
    |> cast(attrs, [:session_duration, :short_break, :long_break, :sessions_before_long_break])
    |> validate_required([
      :session_duration,
      :short_break,
      :long_break,
      :sessions_before_long_break
    ])
    |> validate_number(:session_duration, greater_than: 0)
    |> validate_number(:short_break, greater_than: 0)
    |> validate_number(:long_break, greater_than: 0)
    |> validate_number(:sessions_before_long_break, greater_than: 0)
  end
end
