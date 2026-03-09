# PomodoRob — Task Tracker

## Phase 1: Project Setup

- [x] #1 Generate Phoenix project scaffold
- [x] #2 Add dependencies (TermUI, Credo)
- [x] #3 Configure database and application settings
- [x] #4 Initialize git repo and create .gitignore

## Phase 2: Database Layer

- [x] #5 Create Category schema and migration
- [x] #6 Create Settings schema and migration
- [x] #7 Create Session schema and migration
- [x] #8 Create seeds file for default data

## Phase 3: Core Context

**Category track:**
- [ ] #9 Implement Category CRUD in Pomodoro context
- [ ] #10 Write tests for Category CRUD

**Settings track:**
- [ ] #11 Implement Settings functions in Pomodoro context
- [ ] #12 Write tests for Settings functions

**Session track:**
- [ ] #13 Implement Session CRUD in Pomodoro context
- [ ] #14 Implement Session query functions
- [ ] #15 Write tests for Session CRUD and queries

**Stats:**
- [ ] #16 Implement stats functions in Pomodoro context
- [ ] #17 Write tests for stats functions

## Phase 4: Timer GenServer

- [ ] #18 Implement Timer GenServer — core start/tick/complete
- [ ] #19 Add pause/resume/cancel to Timer GenServer
- [ ] #20 Implement break logic in Timer GenServer
- [ ] #21 Add Timer to supervision tree
- [ ] #22 Write tests for Timer GenServer

## Phase 5: Web UI

- [ ] #23 Set up web layout, navigation, and styling
- [ ] #24 Create Timer LiveView — countdown display and controls
- [ ] #25 Add category selection to Timer LiveView
- [ ] #26 Add break prompt and notes input to Timer LiveView
- [ ] #27 Add audio/visual notification on timer completion (web)
- [ ] #28 Create Sessions LiveView — history list
- [ ] #29 Add delete and notes editing to Sessions LiveView
- [ ] #30 Create Categories LiveView — CRUD management
- [ ] #31 Create Stats LiveView — today's count and grouped stats
- [ ] #32 Add bar chart visualization to Stats LiveView
- [ ] #33 Create Settings LiveView
- [ ] #34 Write LiveView tests for all web pages

## Phase 6: TUI

- [ ] #35 Set up TermUI TUI app and supervision
- [ ] #36 Create TUI timer view
- [ ] #37 Create TUI category selection
- [ ] #38 Create TUI today's sessions and stats views
- [ ] #39 Add bell notification on TUI timer completion
- [ ] #40 Write tests for TUI modules
