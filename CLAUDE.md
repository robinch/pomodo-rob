# PomodoRob

Pomodoro Tracker — a personal time-management app with both a Phoenix LiveView web interface and a Ratatouille terminal UI. Single-user, no auth.

See `FEATURES.md` for the full feature spec.

## Tech Stack

- Elixir 1.19+ / OTP 28+
- Phoenix 1.8+ / LiveView 1.1+
- Ecto + PostgreSQL
- Ratatouille (terminal UI)
- Credo (linting)

## Project Structure

Single Phoenix app (not umbrella). Module namespaces:

- `PomodoRob.Pomodoro.*` — Core business logic (contexts, schemas). Both interfaces consume these modules.
- `PomodoRobWeb.*` — Phoenix web interface (LiveView, controllers, components)
- `PomodoRob.TUI.*` — Ratatouille terminal interface

```
lib/
  pomodo_rob/
    pomodoro/          # Core context: sessions, categories, settings, timer logic
    tui/               # Ratatouille views and app
    application.ex
  pomodo_rob_web/
    live/              # LiveView modules
    components/        # Phoenix components
    router.ex
```

## Database Schemas

- `PomodoRob.Pomodoro.Session` — duration, started_at, completed_at, notes, status, belongs_to category
- `PomodoRob.Pomodoro.Category` — name, color
- `PomodoRob.Pomodoro.Settings` — session_duration, short_break, long_break, sessions_before_long_break

## Development Commands

```bash
mix setup          # Install deps, create/migrate DB, seed defaults
mix phx.server     # Start web server (localhost:4000)
mix test           # Run tests
mix test --cover   # Run tests with coverage
mix format         # Format code
mix credo          # Lint
mix ecto.migrate   # Run migrations
mix ecto.rollback  # Rollback last migration
```

## Code Conventions

- Run `mix format` before committing — project uses standard Elixir formatter (`.formatter.exs`)
- Run `mix credo --strict` for linting
- Follow standard Phoenix patterns: contexts for business logic, schemas for data, LiveView for interactivity
- Tests go in `test/` mirroring `lib/` structure. Use `ExUnit` with `async: true` where possible
- Context modules expose the public API; schemas are not used directly outside contexts
- Keep core logic in `PomodoRob.Pomodoro.*` decoupled from both web and TUI — no Phoenix or Ratatouille deps in core modules

## Architecture Notes

- Timer state is managed in a process (GenServer), not in the database. Sessions are persisted only on completion.
- The core `Pomodoro` context handles all business rules. Web and TUI are thin presentation layers.
- Default categories ("Work", "Study", "Personal") are seeded on first run via `priv/repo/seeds.exs`.

## Workflow & Task Tracking

- **`TASKS.md`** — master checklist of all 40 tasks, grouped by phase. Check off tasks as completed.
- **GitHub Issues** — each task is a GitHub Issue (#1–#40) with phase labels (`phase:1-setup` through `phase:6-tui`). Close issues as tasks are completed.
- **GitHub repo**: https://github.com/robinch/pomodo-rob (private)

### Execution order

Tasks are organized in 6 phases with dependencies. Work them in order:

1. **Phase 1: Project Setup** (#1–#4) — Phoenix scaffold, deps, DB config, git
2. **Phase 2: Database Layer** (#5–#8) — schemas, migrations, seeds
3. **Phase 3: Core Context** (#9–#17) — CRUD, queries, stats (Category/Settings/Session tracks can be parallel)
4. **Phase 4: Timer GenServer** (#18–#22) — start/tick/complete, pause/resume/cancel, breaks, supervision
5. **Phase 5: Web UI** (#23–#34) — layout, LiveView pages (Timer, Sessions, Categories, Stats, Settings)
6. **Phase 6: TUI** (#35–#40) — Ratatouille terminal interface

### When completing a task

1. Mark the checkbox in `TASKS.md` (`- [x]`)
2. Close the GitHub Issue: `gh issue close <number>`
3. Commit the work
4. Check what's next by reviewing TASKS.md for the next unchecked item

### Verification after each phase

- `mix compile --warnings-as-errors`
- `mix test`
- `mix format --check-formatted`
- `mix credo --strict`
