defmodule PomodoRob.Pomodoro do
  @moduledoc """
  The Pomodoro context — public API for sessions, categories, and settings.
  """

  import Ecto.Query

  alias PomodoRob.Pomodoro.Category
  alias PomodoRob.Pomodoro.Session
  alias PomodoRob.Pomodoro.Settings
  alias PomodoRob.Repo

  # ---------------------------------------------------------------------------
  # Categories
  # ---------------------------------------------------------------------------

  @doc "Returns all categories ordered by name."
  @spec list_categories() :: [Category.t()]
  def list_categories do
    Category |> order_by([c], asc: c.name) |> Repo.all()
  end

  @doc "Gets a category by id. Raises `Ecto.NoResultsError` if not found."
  @spec get_category!(integer()) :: Category.t()
  def get_category!(id), do: Repo.get!(Category, id)

  @doc "Gets a category by id. Returns `nil` if not found."
  @spec get_category(integer()) :: Category.t() | nil
  def get_category(id), do: Repo.get(Category, id)

  @doc "Creates a category with the given attrs."
  @spec create_category(map()) :: {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Updates a category with the given attrs."
  @spec update_category(Category.t(), map()) :: {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc "Deletes a category."
  @spec delete_category(Category.t()) :: {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc "Returns a changeset for the given category and optional attrs."
  @spec change_category(Category.t(), map()) :: Ecto.Changeset.t()
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  # ---------------------------------------------------------------------------
  # Settings
  # ---------------------------------------------------------------------------

  @doc "Returns the single settings row. Raises if none exist."
  @spec get_settings!() :: Settings.t()
  def get_settings! do
    Repo.one!(Settings)
  end

  @doc "Updates the settings with the given attrs."
  @spec update_settings(Settings.t(), map()) :: {:ok, Settings.t()} | {:error, Ecto.Changeset.t()}
  def update_settings(%Settings{} = settings, attrs) do
    settings
    |> Settings.changeset(attrs)
    |> Repo.update()
  end

  @doc "Returns a changeset for the given settings and optional attrs."
  @spec change_settings(Settings.t(), map()) :: Ecto.Changeset.t()
  def change_settings(%Settings{} = settings, attrs \\ %{}) do
    Settings.changeset(settings, attrs)
  end

  # ---------------------------------------------------------------------------
  # Sessions
  # ---------------------------------------------------------------------------

  @doc """
  Returns sessions ordered by started_at descending, with category preloaded.

  Accepts optional filters:
  - `:category_id` — filter by category
  - `:status` — filter by status ("completed" or "cancelled")
  - `:date` — filter to sessions started on a given `Date`
  """
  @spec list_sessions(keyword()) :: [Session.t()]
  def list_sessions(filters \\ []) do
    filters
    |> Enum.reduce(Session, fn
      {:category_id, id}, query ->
        where(query, [s], s.category_id == ^id)

      {:status, status}, query ->
        where(query, [s], s.status == ^status)

      {:date, date}, query ->
        start = DateTime.new!(date, ~T[00:00:00], "Etc/UTC")
        finish = DateTime.new!(Date.add(date, 1), ~T[00:00:00], "Etc/UTC")
        where(query, [s], s.started_at >= ^start and s.started_at < ^finish)
    end)
    |> order_by([s], desc: s.started_at)
    |> preload(:category)
    |> Repo.all()
  end

  @doc "Gets a session by id. Raises `Ecto.NoResultsError` if not found."
  @spec get_session!(integer()) :: Session.t()
  def get_session!(id) do
    Session
    |> preload(:category)
    |> Repo.get!(id)
  end

  @doc "Creates a session with the given attrs."
  @spec create_session(map()) :: {:ok, Session.t()} | {:error, Ecto.Changeset.t()}
  def create_session(attrs \\ %{}) do
    %Session{}
    |> Session.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Updates a session with the given attrs."
  @spec update_session(Session.t(), map()) :: {:ok, Session.t()} | {:error, Ecto.Changeset.t()}
  def update_session(%Session{} = session, attrs) do
    session
    |> Session.changeset(attrs)
    |> Repo.update()
  end

  @doc "Deletes a session."
  @spec delete_session(Session.t()) :: {:ok, Session.t()} | {:error, Ecto.Changeset.t()}
  def delete_session(%Session{} = session) do
    Repo.delete(session)
  end

  @doc "Returns a changeset for the given session and optional attrs."
  @spec change_session(Session.t(), map()) :: Ecto.Changeset.t()
  def change_session(%Session{} = session, attrs \\ %{}) do
    Session.changeset(session, attrs)
  end

  @doc "Returns completed sessions started today, ordered by started_at desc."
  @spec list_sessions_today() :: [Session.t()]
  def list_sessions_today do
    list_sessions(status: "completed", date: Date.utc_today())
  end

  @doc "Returns completed sessions started within the given date range (inclusive), ordered by started_at desc."
  @spec list_sessions_by_date_range(Date.t(), Date.t()) :: [Session.t()]
  def list_sessions_by_date_range(%Date{} = from, %Date{} = to) do
    start = DateTime.new!(from, ~T[00:00:00], "Etc/UTC")
    finish = DateTime.new!(Date.add(to, 1), ~T[00:00:00], "Etc/UTC")

    Session
    |> where([s], s.status == "completed")
    |> where([s], s.started_at >= ^start and s.started_at < ^finish)
    |> order_by([s], desc: s.started_at)
    |> preload(:category)
    |> Repo.all()
  end

  @doc "Returns completed sessions for the given category, ordered by started_at desc."
  @spec list_sessions_by_category(integer()) :: [Session.t()]
  def list_sessions_by_category(category_id) do
    list_sessions(status: "completed", category_id: category_id)
  end
end
