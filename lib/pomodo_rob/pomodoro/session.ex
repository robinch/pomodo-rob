defmodule PomodoRob.Pomodoro.Session do
  use Ecto.Schema
  import Ecto.Changeset

  alias PomodoRob.Pomodoro.Category

  @valid_statuses ["completed", "cancelled"]

  schema "sessions" do
    field :duration, :integer
    field :started_at, :utc_datetime
    field :completed_at, :utc_datetime
    field :notes, :string
    field :status, :string, default: "completed"
    belongs_to :category, Category

    timestamps(type: :utc_datetime)
  end

  def changeset(session, attrs) do
    session
    |> cast(attrs, [:duration, :started_at, :completed_at, :notes, :status, :category_id])
    |> validate_required([:duration, :started_at, :status])
    |> validate_number(:duration, greater_than: 0)
    |> validate_inclusion(:status, @valid_statuses)
    |> foreign_key_constraint(:category_id)
  end
end
