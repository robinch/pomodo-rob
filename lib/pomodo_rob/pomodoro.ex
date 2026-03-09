defmodule PomodoRob.Pomodoro do
  @moduledoc """
  The Pomodoro context — public API for sessions, categories, and settings.
  """

  import Ecto.Query

  alias PomodoRob.Pomodoro.Category
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
end
