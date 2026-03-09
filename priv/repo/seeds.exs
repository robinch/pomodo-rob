# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PomodoRob.Repo.insert!(%PomodoRob.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias PomodoRob.Repo
alias PomodoRob.Pomodoro.Category
alias PomodoRob.Pomodoro.Settings

# Default categories
categories = [
  %{name: "Work", color: "#ef4444"},
  %{name: "Study", color: "#3b82f6"},
  %{name: "Personal", color: "#22c55e"}
]

Enum.each(categories, fn attrs ->
  case Repo.get_by(Category, name: attrs.name) do
    nil -> Repo.insert!(Category.changeset(%Category{}, attrs))
    _existing -> :ok
  end
end)

# Default settings (only insert if none exist)
if Repo.aggregate(Settings, :count) == 0 do
  Repo.insert!(
    Settings.changeset(%Settings{}, %{
      session_duration: 25,
      short_break: 5,
      long_break: 15,
      sessions_before_long_break: 4
    })
  )
end
