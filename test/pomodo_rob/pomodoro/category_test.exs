defmodule PomodoRob.Pomodoro.CategoryTest do
  use PomodoRob.DataCase, async: true

  alias PomodoRob.Pomodoro
  alias PomodoRob.Pomodoro.Category

  describe "list_categories/0" do
    test "returns all categories" do
      {:ok, cat} = Pomodoro.create_category(%{name: "Work", color: "#ff0000"})
      assert cat in Pomodoro.list_categories()
    end

    test "returns categories ordered by name" do
      {:ok, _} = Pomodoro.create_category(%{name: "Work", color: "#ff0000"})
      {:ok, _} = Pomodoro.create_category(%{name: "Personal", color: "#00ff00"})
      {:ok, _} = Pomodoro.create_category(%{name: "Study", color: "#0000ff"})
      names = Pomodoro.list_categories() |> Enum.map(& &1.name)
      assert names == Enum.sort(names)
    end

    test "returns empty list when no categories exist" do
      assert Pomodoro.list_categories() == []
    end
  end

  describe "get_category!/1" do
    test "returns the category with the given id" do
      {:ok, cat} = Pomodoro.create_category(%{name: "Work", color: "#ff0000"})
      assert Pomodoro.get_category!(cat.id) == cat
    end

    test "raises if category not found" do
      assert_raise Ecto.NoResultsError, fn ->
        Pomodoro.get_category!(0)
      end
    end
  end

  describe "get_category/1" do
    test "returns the category with the given id" do
      {:ok, cat} = Pomodoro.create_category(%{name: "Work", color: "#ff0000"})
      assert Pomodoro.get_category(cat.id) == cat
    end

    test "returns nil if not found" do
      assert Pomodoro.get_category(0) == nil
    end
  end

  describe "create_category/1" do
    test "with valid attrs creates a category" do
      assert {:ok, %Category{} = cat} =
               Pomodoro.create_category(%{name: "Work", color: "#ff0000"})

      assert cat.name == "Work"
      assert cat.color == "#ff0000"
    end

    test "missing name returns error changeset" do
      assert {:error, changeset} = Pomodoro.create_category(%{color: "#ff0000"})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "missing color returns error changeset" do
      assert {:error, changeset} = Pomodoro.create_category(%{name: "Work"})
      assert %{color: ["can't be blank"]} = errors_on(changeset)
    end

    test "duplicate name returns error changeset" do
      {:ok, _} = Pomodoro.create_category(%{name: "Work", color: "#ff0000"})
      assert {:error, changeset} = Pomodoro.create_category(%{name: "Work", color: "#0000ff"})
      assert %{name: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "update_category/2" do
    test "with valid attrs updates the category" do
      {:ok, cat} = Pomodoro.create_category(%{name: "Work", color: "#ff0000"})
      assert {:ok, updated} = Pomodoro.update_category(cat, %{name: "Study", color: "#0000ff"})
      assert updated.name == "Study"
      assert updated.color == "#0000ff"
    end

    test "with invalid attrs returns error changeset" do
      {:ok, cat} = Pomodoro.create_category(%{name: "Work", color: "#ff0000"})
      assert {:error, changeset} = Pomodoro.update_category(cat, %{name: nil})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "duplicate name returns error changeset" do
      {:ok, _} = Pomodoro.create_category(%{name: "Work", color: "#ff0000"})
      {:ok, cat2} = Pomodoro.create_category(%{name: "Study", color: "#0000ff"})
      assert {:error, changeset} = Pomodoro.update_category(cat2, %{name: "Work"})
      assert %{name: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "delete_category/1" do
    test "deletes the category" do
      {:ok, cat} = Pomodoro.create_category(%{name: "Work", color: "#ff0000"})
      assert {:ok, %Category{}} = Pomodoro.delete_category(cat)
      assert Pomodoro.get_category(cat.id) == nil
    end
  end

  describe "change_category/2" do
    test "returns a changeset for the category" do
      {:ok, cat} = Pomodoro.create_category(%{name: "Work", color: "#ff0000"})
      assert %Ecto.Changeset{} = Pomodoro.change_category(cat)
    end

    test "applies attrs to the changeset" do
      {:ok, cat} = Pomodoro.create_category(%{name: "Work", color: "#ff0000"})
      changeset = Pomodoro.change_category(cat, %{name: "Study"})
      assert changeset.changes == %{name: "Study"}
    end
  end
end
