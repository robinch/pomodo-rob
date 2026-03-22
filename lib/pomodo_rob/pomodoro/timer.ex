defmodule PomodoRob.Pomodoro.Timer do
  @moduledoc """
  GenServer that manages a pomodoro timer countdown.

  Ticks every second via `Process.send_after/3`. When the countdown
  reaches zero the session is persisted to the database and a
  `:completed` broadcast is sent over PubSub.

  ## State

      %{
        status:            :idle | :running | :completed,
        remaining_seconds: non_neg_integer(),
        category_id:       integer() | nil,
        started_at:        DateTime.t() | nil,
        session_count:     non_neg_integer()
      }
  """

  use GenServer

  alias PomodoRob.Pomodoro

  @pubsub PomodoRob.PubSub
  @topic "timer"

  # ── Client API ──────────────────────────────────────────────────────

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc """
  Starts a new pomodoro timer.

  `category_id` may be `nil`. `duration_minutes` is the length of the
  session in minutes.
  """
  def start_timer(category_id, duration_minutes, name \\ __MODULE__) do
    GenServer.call(name, {:start_timer, category_id, duration_minutes})
  end

  @doc "Returns the current timer state as a map."
  def get_state(name \\ __MODULE__) do
    GenServer.call(name, :get_state)
  end

  @doc "Returns the PubSub topic used for timer broadcasts."
  def topic, do: @topic

  # ── Server callbacks ────────────────────────────────────────────────

  @impl true
  def init(_opts) do
    {:ok, initial_state()}
  end

  @impl true
  def handle_call({:start_timer, _category_id, _duration}, _from, %{status: :running} = state) do
    {:reply, {:error, :already_running}, state}
  end

  def handle_call({:start_timer, category_id, duration_minutes}, _from, state) do
    remaining = duration_minutes * 60

    new_state = %{
      state
      | status: :running,
        remaining_seconds: remaining,
        category_id: category_id,
        started_at: DateTime.utc_now()
    }

    schedule_tick()
    broadcast(new_state)

    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info(:tick, %{status: :running, remaining_seconds: remaining} = state)
      when remaining <= 1 do
    new_state = complete_session(state)
    broadcast(new_state)
    {:noreply, new_state}
  end

  def handle_info(:tick, %{status: :running} = state) do
    new_state = %{state | remaining_seconds: state.remaining_seconds - 1}
    schedule_tick()
    broadcast(new_state)
    {:noreply, new_state}
  end

  def handle_info(:tick, state) do
    # Ignore stale ticks when not running
    {:noreply, state}
  end

  # ── Private helpers ─────────────────────────────────────────────────

  defp initial_state do
    %{
      status: :idle,
      remaining_seconds: 0,
      category_id: nil,
      started_at: nil,
      session_count: 0
    }
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, 1_000)
  end

  defp complete_session(state) do
    now = DateTime.utc_now()
    duration = DateTime.diff(now, state.started_at, :second)

    attrs = %{
      duration: duration,
      started_at: state.started_at,
      completed_at: now,
      status: "completed",
      category_id: state.category_id
    }

    {:ok, _session} = Pomodoro.create_session(attrs)

    %{
      state
      | status: :completed,
        remaining_seconds: 0,
        session_count: state.session_count + 1
    }
  end

  defp broadcast(state) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {:timer_update, state})
  end
end
