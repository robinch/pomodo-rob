defmodule PomodoRob.Pomodoro.SettingsTest do
  use PomodoRob.DataCase, async: true

  alias PomodoRob.Pomodoro
  alias PomodoRob.Pomodoro.Settings
  alias PomodoRob.Repo

  defp insert_settings(attrs \\ %{}) do
    defaults = %{
      session_duration: 25,
      short_break: 5,
      long_break: 15,
      sessions_before_long_break: 4
    }

    {:ok, settings} =
      %Settings{}
      |> Settings.changeset(Map.merge(defaults, attrs))
      |> Repo.insert()

    settings
  end

  describe "get_settings!/0" do
    test "returns the settings row" do
      settings = insert_settings()
      assert Pomodoro.get_settings!() == settings
    end

    test "raises if no settings exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Pomodoro.get_settings!()
      end
    end
  end

  describe "update_settings/2" do
    test "with valid attrs updates the settings" do
      settings = insert_settings()

      assert {:ok, updated} =
               Pomodoro.update_settings(settings, %{
                 session_duration: 30,
                 short_break: 10,
                 long_break: 20,
                 sessions_before_long_break: 3
               })

      assert updated.session_duration == 30
      assert updated.short_break == 10
      assert updated.long_break == 20
      assert updated.sessions_before_long_break == 3
    end

    test "partial update only changes given fields" do
      settings = insert_settings()
      assert {:ok, updated} = Pomodoro.update_settings(settings, %{session_duration: 50})
      assert updated.session_duration == 50
      assert updated.short_break == 5
      assert updated.long_break == 15
      assert updated.sessions_before_long_break == 4
    end

    test "zero session_duration returns error changeset" do
      settings = insert_settings()
      assert {:error, changeset} = Pomodoro.update_settings(settings, %{session_duration: 0})
      assert %{session_duration: [_]} = errors_on(changeset)
    end

    test "negative short_break returns error changeset" do
      settings = insert_settings()
      assert {:error, changeset} = Pomodoro.update_settings(settings, %{short_break: -1})
      assert %{short_break: [_]} = errors_on(changeset)
    end

    test "nil long_break returns error changeset" do
      settings = insert_settings()
      assert {:error, changeset} = Pomodoro.update_settings(settings, %{long_break: nil})
      assert %{long_break: [_]} = errors_on(changeset)
    end

    test "zero sessions_before_long_break returns error changeset" do
      settings = insert_settings()

      assert {:error, changeset} =
               Pomodoro.update_settings(settings, %{sessions_before_long_break: 0})

      assert %{sessions_before_long_break: [_]} = errors_on(changeset)
    end
  end

  describe "change_settings/2" do
    test "returns a changeset for the settings" do
      settings = insert_settings()
      assert %Ecto.Changeset{} = Pomodoro.change_settings(settings)
    end

    test "applies attrs to the changeset" do
      settings = insert_settings()
      changeset = Pomodoro.change_settings(settings, %{session_duration: 45})
      assert changeset.changes == %{session_duration: 45}
    end
  end
end
