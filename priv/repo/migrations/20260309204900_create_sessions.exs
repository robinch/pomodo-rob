defmodule PomodoRob.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :duration, :integer, null: false
      add :started_at, :utc_datetime, null: false
      add :completed_at, :utc_datetime
      add :notes, :text
      add :status, :string, null: false, default: "completed"
      add :category_id, references(:categories, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:sessions, [:category_id])
    create index(:sessions, [:started_at])
  end
end
