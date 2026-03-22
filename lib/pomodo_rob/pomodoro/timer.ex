defmodule PomodoRob.Pomodoro.Timer do
  @moduledoc """
  GenServer that manages a pomodoro timer countdown.

  Ticks every second via `Process.send_after/3`. When the countdown
  reaches zero the session is persisted to the database and a
  `:completed` broadcast is sent over PubSub.

  ## State

      %{
        status:            :idle | :running | :paused | :completed,
        remaining_seconds: non_neg_integer(),
        category_id:       integer() | nil,
        started_at:        DateTime.t() | nil,
        session_count:     non_neg_integer(),
        tick_ref:          reference() | nil,
        paused_seconds:    non_neg_integer(),
        paused_at:         DateTime.t() | nil
      }
  """

  use GenServer

  require Logger

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

  @doc "Pauses a running timer, preserving remaining time."
  def pause_timer(name \\ __MODULE__) do
    GenServer.call(name, :pause_timer)
  end

  @doc "Resumes a paused timer."
  def resume_timer(name \\ __MODULE__) do
    GenServer.call(name, :resume_timer)
  end

  @doc "Cancels the current timer without saving the session."
  def cancel_timer(name \\ __MODULE__) do
    GenServer.call(name, :cancel_timer)
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
  def handle_call({:start_timer, _category_id, _duration}, _from, %{status: status} = state)
      when status in [:running, :paused] do
    {:reply, {:error, :already_running}, state}
  end

  def handle_call({:start_timer, _category_id, duration}, _from, state)
      when duration <= 0 do
    {:reply, {:error, :invalid_duration}, state}
  end

  def handle_call({:start_timer, category_id, duration_minutes}, _from, state) do
    remaining = duration_minutes * 60

    new_state = %{
      state
      | status: :running,
        remaining_seconds: remaining,
        category_id: category_id,
        started_at: DateTime.utc_now(),
        tick_ref: schedule_tick()
    }

    broadcast(new_state)

    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call(:pause_timer, _from, %{status: :running, tick_ref: ref} = state) do
    cancel_tick(ref)
    new_state = %{state | status: :paused, tick_ref: nil, paused_at: DateTime.utc_now()}
    broadcast(new_state)
    {:reply, :ok, new_state}
  end

  def handle_call(:pause_timer, _from, state) do
    {:reply, {:error, :not_running}, state}
  end

  @impl true
  def handle_call(:resume_timer, _from, %{status: :paused} = state) do
    pause_duration = DateTime.diff(DateTime.utc_now(), state.paused_at, :second)

    new_state = %{
      state
      | status: :running,
        tick_ref: schedule_tick(),
        paused_seconds: state.paused_seconds + pause_duration,
        paused_at: nil
    }

    broadcast(new_state)
    {:reply, :ok, new_state}
  end

  def handle_call(:resume_timer, _from, state) do
    {:reply, {:error, :not_paused}, state}
  end

  @impl true
  def handle_call(:cancel_timer, _from, %{status: status, tick_ref: ref} = state)
      when status in [:running, :paused] do
    cancel_tick(ref)
    new_state = %{initial_state() | session_count: state.session_count}
    broadcast(new_state)
    {:reply, :ok, new_state}
  end

  def handle_call(:cancel_timer, _from, state) do
    {:reply, {:error, :not_active}, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info(:tick, %{status: :running} = state) do
    new_remaining = state.remaining_seconds - 1

    if new_remaining <= 0 do
      new_state = complete_session(state)
      broadcast(new_state)
      {:noreply, new_state}
    else
      new_state = %{state | remaining_seconds: new_remaining, tick_ref: schedule_tick()}
      broadcast(new_state)
      {:noreply, new_state}
    end
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
      session_count: 0,
      tick_ref: nil,
      paused_seconds: 0,
      paused_at: nil
    }
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, 1_000)
  end

  defp cancel_tick(nil), do: :ok

  defp cancel_tick(ref) do
    Process.cancel_timer(ref)
    :ok
  end

  defp complete_session(state) do
    now = DateTime.utc_now()
    wall_clock = DateTime.diff(now, state.started_at, :second)
    duration = wall_clock - state.paused_seconds

    attrs = %{
      duration: duration,
      started_at: state.started_at,
      completed_at: now,
      status: "completed",
      category_id: state.category_id
    }

    case Pomodoro.create_session(attrs) do
      {:ok, _session} ->
        :ok

      {:error, reason} ->
        Logger.warning("Timer: failed to persist session: #{inspect(reason)}")
    end

    %{
      state
      | status: :completed,
        remaining_seconds: 0,
        session_count: state.session_count + 1,
        tick_ref: nil
    }
  end

  defp broadcast(state) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {:timer_update, state})
  end
end
