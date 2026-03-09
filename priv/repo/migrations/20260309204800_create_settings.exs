defmodule PomodoRob.Repo.Migrations.CreateSettings do
  use Ecto.Migration

  def change do
    create table(:settings) do
      add :session_duration, :integer, null: false, default: 25
      add :short_break, :integer, null: false, default: 5
      add :long_break, :integer, null: false, default: 15
      add :sessions_before_long_break, :integer, null: false, default: 4

      timestamps(type: :utc_datetime)
    end
  end
end
