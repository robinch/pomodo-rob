defmodule PomodoRob.Pomodoro.SessionTest do
  use PomodoRob.DataCase, async: true

  alias PomodoRob.Pomodoro
  alias PomodoRob.Pomodoro.Session

  defp insert_category(attrs \\ %{}) do
    defaults = %{name: "Work", color: "#ff0000"}
    {:ok, cat} = Pomodoro.create_category(Map.merge(defaults, attrs))
    cat
  end

  defp insert_session(attrs \\ %{}) do
    defaults = %{
      duration: 1500,
      started_at: ~U[2026-03-09 09:00:00Z],
      status: "completed"
    }

    {:ok, session} = Pomodoro.create_session(Map.merge(defaults, attrs))
    session
  end

  describe "list_sessions/1" do
    test "returns all sessions ordered by started_at desc" do
      s1 = insert_session(%{started_at: ~U[2026-03-09 08:00:00Z]})
      s2 = insert_session(%{started_at: ~U[2026-03-09 10:00:00Z]})
      ids = Pomodoro.list_sessions() |> Enum.map(& &1.id)
      assert ids == [s2.id, s1.id]
    end

    test "returns empty list when no sessions exist" do
      assert Pomodoro.list_sessions() == []
    end

    test "preloads category" do
      cat = insert_category()
      insert_session(%{category_id: cat.id})
      [session] = Pomodoro.list_sessions()
      assert session.category.id == cat.id
    end

    test "filters by category_id" do
      cat1 = insert_category(%{name: "Work", color: "#ff0000"})
      cat2 = insert_category(%{name: "Study", color: "#0000ff"})
      s1 = insert_session(%{category_id: cat1.id})
      _s2 = insert_session(%{category_id: cat2.id})
      ids = Pomodoro.list_sessions(category_id: cat1.id) |> Enum.map(& &1.id)
      assert ids == [s1.id]
    end

    test "filters by status" do
      s1 = insert_session(%{status: "completed"})
      _s2 = insert_session(%{status: "cancelled"})
      ids = Pomodoro.list_sessions(status: "completed") |> Enum.map(& &1.id)
      assert ids == [s1.id]
    end

    test "filters by date" do
      s1 = insert_session(%{started_at: ~U[2026-03-09 09:00:00Z]})
      _s2 = insert_session(%{started_at: ~U[2026-03-08 09:00:00Z]})
      ids = Pomodoro.list_sessions(date: ~D[2026-03-09]) |> Enum.map(& &1.id)
      assert ids == [s1.id]
    end

    test "multiple filters are combined" do
      cat = insert_category()
      s1 = insert_session(%{category_id: cat.id, status: "completed"})
      _s2 = insert_session(%{category_id: cat.id, status: "cancelled"})
      ids = Pomodoro.list_sessions(category_id: cat.id, status: "completed") |> Enum.map(& &1.id)
      assert ids == [s1.id]
    end
  end

  describe "get_session!/1" do
    test "returns the session with preloaded category" do
      cat = insert_category()
      session = insert_session(%{category_id: cat.id})
      fetched = Pomodoro.get_session!(session.id)
      assert fetched.id == session.id
      assert fetched.category.id == cat.id
    end

    test "raises if session not found" do
      assert_raise Ecto.NoResultsError, fn ->
        Pomodoro.get_session!(0)
      end
    end
  end

  describe "create_session/1" do
    test "with valid attrs creates a session" do
      assert {:ok, %Session{} = session} =
               Pomodoro.create_session(%{
                 duration: 1500,
                 started_at: ~U[2026-03-09 09:00:00Z],
                 status: "completed"
               })

      assert session.duration == 1500
      assert session.status == "completed"
    end

    test "with a category creates a session linked to it" do
      cat = insert_category()

      assert {:ok, session} =
               Pomodoro.create_session(%{
                 duration: 1500,
                 started_at: ~U[2026-03-09 09:00:00Z],
                 status: "completed",
                 category_id: cat.id
               })

      assert session.category_id == cat.id
    end

    test "missing duration returns error changeset" do
      assert {:error, changeset} =
               Pomodoro.create_session(%{
                 started_at: ~U[2026-03-09 09:00:00Z],
                 status: "completed"
               })

      assert %{duration: ["can't be blank"]} = errors_on(changeset)
    end

    test "zero duration returns error changeset" do
      assert {:error, changeset} =
               Pomodoro.create_session(%{
                 duration: 0,
                 started_at: ~U[2026-03-09 09:00:00Z],
                 status: "completed"
               })

      assert %{duration: [_]} = errors_on(changeset)
    end

    test "missing started_at returns error changeset" do
      assert {:error, changeset} =
               Pomodoro.create_session(%{duration: 1500, status: "completed"})

      assert %{started_at: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid status returns error changeset" do
      assert {:error, changeset} =
               Pomodoro.create_session(%{
                 duration: 1500,
                 started_at: ~U[2026-03-09 09:00:00Z],
                 status: "invalid"
               })

      assert %{status: [_]} = errors_on(changeset)
    end

    test "invalid category_id returns error changeset" do
      assert {:error, changeset} =
               Pomodoro.create_session(%{
                 duration: 1500,
                 started_at: ~U[2026-03-09 09:00:00Z],
                 status: "completed",
                 category_id: 0
               })

      assert %{category_id: [_]} = errors_on(changeset)
    end
  end

  describe "update_session/2" do
    test "updates the notes field" do
      session = insert_session()
      assert {:ok, updated} = Pomodoro.update_session(session, %{notes: "Great focus session"})
      assert updated.notes == "Great focus session"
    end

    test "updates the status field" do
      session = insert_session(%{status: "completed"})
      assert {:ok, updated} = Pomodoro.update_session(session, %{status: "cancelled"})
      assert updated.status == "cancelled"
    end

    test "invalid status returns error changeset" do
      session = insert_session()
      assert {:error, changeset} = Pomodoro.update_session(session, %{status: "invalid"})
      assert %{status: [_]} = errors_on(changeset)
    end
  end

  describe "delete_session/1" do
    test "deletes the session" do
      session = insert_session()
      assert {:ok, %Session{}} = Pomodoro.delete_session(session)

      assert_raise Ecto.NoResultsError, fn ->
        Pomodoro.get_session!(session.id)
      end
    end
  end

  describe "change_session/2" do
    test "returns a changeset for the session" do
      session = insert_session()
      assert %Ecto.Changeset{} = Pomodoro.change_session(session)
    end

    test "applies attrs to the changeset" do
      session = insert_session()
      changeset = Pomodoro.change_session(session, %{notes: "Nice"})
      assert changeset.changes == %{notes: "Nice"}
    end
  end

  describe "list_sessions_today/0" do
    test "returns completed sessions started today" do
      today = Date.utc_today()
      started_today = DateTime.new!(today, ~T[09:00:00], "Etc/UTC")
      yesterday = DateTime.new!(Date.add(today, -1), ~T[09:00:00], "Etc/UTC")

      s1 = insert_session(%{started_at: started_today, status: "completed"})
      _s2 = insert_session(%{started_at: yesterday, status: "completed"})
      _s3 = insert_session(%{started_at: started_today, status: "cancelled"})

      ids = Pomodoro.list_sessions_today() |> Enum.map(& &1.id)
      assert ids == [s1.id]
    end

    test "returns empty list when no sessions today" do
      yesterday = DateTime.new!(Date.add(Date.utc_today(), -1), ~T[09:00:00], "Etc/UTC")
      insert_session(%{started_at: yesterday})
      assert Pomodoro.list_sessions_today() == []
    end
  end

  describe "list_sessions_by_date_range/2" do
    test "returns completed sessions within the date range" do
      s1 = insert_session(%{started_at: ~U[2026-03-08 09:00:00Z], status: "completed"})
      s2 = insert_session(%{started_at: ~U[2026-03-09 09:00:00Z], status: "completed"})
      s3 = insert_session(%{started_at: ~U[2026-03-10 09:00:00Z], status: "completed"})
      _outside = insert_session(%{started_at: ~U[2026-03-11 09:00:00Z], status: "completed"})
      _cancelled = insert_session(%{started_at: ~U[2026-03-09 10:00:00Z], status: "cancelled"})

      ids =
        Pomodoro.list_sessions_by_date_range(~D[2026-03-08], ~D[2026-03-10])
        |> Enum.map(& &1.id)

      assert ids == [s3.id, s2.id, s1.id]
    end

    test "returns empty list when no sessions in range" do
      insert_session(%{started_at: ~U[2026-03-01 09:00:00Z]})

      assert Pomodoro.list_sessions_by_date_range(~D[2026-03-08], ~D[2026-03-10]) == []
    end

    test "single-day range works" do
      s1 = insert_session(%{started_at: ~U[2026-03-09 08:00:00Z], status: "completed"})
      s2 = insert_session(%{started_at: ~U[2026-03-09 10:00:00Z], status: "completed"})
      _outside = insert_session(%{started_at: ~U[2026-03-10 09:00:00Z], status: "completed"})

      ids =
        Pomodoro.list_sessions_by_date_range(~D[2026-03-09], ~D[2026-03-09])
        |> Enum.map(& &1.id)

      assert ids == [s2.id, s1.id]
    end
  end

  describe "list_sessions_by_category/1" do
    test "returns completed sessions for the given category" do
      cat1 = insert_category(%{name: "Work", color: "#ff0000"})
      cat2 = insert_category(%{name: "Study", color: "#0000ff"})
      s1 = insert_session(%{category_id: cat1.id, status: "completed"})
      _s2 = insert_session(%{category_id: cat2.id, status: "completed"})
      _s3 = insert_session(%{category_id: cat1.id, status: "cancelled"})

      ids = Pomodoro.list_sessions_by_category(cat1.id) |> Enum.map(& &1.id)
      assert ids == [s1.id]
    end

    test "returns empty list when no sessions for category" do
      cat = insert_category()
      assert Pomodoro.list_sessions_by_category(cat.id) == []
    end
  end
end
