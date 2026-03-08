# Pomodoro Tracker — Feature Spec

## What is it?
A personal time-management app based on the Pomodoro Technique. Track focused work sessions, categorize your work, and review how you spend your time. Available as both a web app (Phoenix LiveView) and a terminal interface (TermUI TUI).

---

## Core Concepts

- **Session**: A timed block of focused work (default 25 min)
- **Break**: A rest period after a session (short: 5 min, long: 15 min)
- **Category**: A label for what you're working on (e.g. "coding", "reading", "planning")

---

## Features

### Timer
- [ ] Start a pomodoro session with a countdown timer
- [ ] Pause and resume the timer
- [ ] Cancel a session (discards it, not saved)
- [ ] Timer auto-completes when countdown reaches zero
- [ ] Audio/visual notification when timer completes (web), bell (TUI)
- [ ] After a session completes, prompt for a short break
- [ ] Every 4 sessions, suggest a long break

### Sessions
- [ ] Assign a category when starting a session
- [ ] Add optional notes to a session (before or after)
- [ ] View history of completed sessions
- [ ] Delete a session from history

### Categories
- [ ] Create custom categories
- [ ] Edit category name
- [ ] Delete a category (sessions keep a reference)
- [ ] Default categories provided on first run (e.g. "Work", "Study", "Personal")

### Stats & Reporting
- [ ] View total sessions completed today
- [ ] View sessions grouped by category (today / this week / this month)
- [ ] View daily streak (consecutive days with at least 1 session)
- [ ] Simple bar/chart breakdown by category

### Settings
- [ ] Configure session duration (default 25 min)
- [ ] Configure short break duration (default 5 min)
- [ ] Configure long break duration (default 15 min)
- [ ] Configure how many sessions before a long break (default 4)

---

## Interfaces

### Web (Phoenix LiveView)
All features above available through the browser.

### TUI (TermUI)
Core features available in the terminal:
- Start/pause/cancel timer
- Select category
- View today's sessions
- View basic stats
- Charts/visual stats can be added later (TermUI supports chart widgets)

---

## Out of Scope (for now)
- Multi-user / authentication
- Team features
- Mobile app
- External integrations (calendar, Slack, etc.)
- Data export
