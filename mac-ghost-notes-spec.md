# Mac Ghost Notes App Spec

## Overview

This document defines a very small macOS app for displaying personal presentation notes in a lightweight overlay window.

The app is inspired by:

- [ScreenPrompt](https://github.com/dan0dev/ScreenPrompt)
- [GhostLayer](https://github.com/HelithaSri/GhostLayer)

The goal is to start with the smallest useful version and then iterate toward features like auto-scroll, keyboard shortcuts, and click-through mode.

## Product Goal

Create a lightweight macOS app that lets a user paste notes into a floating overlay window and keep those notes visible while presenting, screen sharing, or recording.

The first version should prioritize:

- Fast startup
- Simple note entry
- Local-only storage
- Minimal UI
- Native macOS behavior

## Non-Goals For The First Version

The first version should not try to solve everything.

Out of scope for v1:

- Multi-note organization
- Cloud sync
- Accounts or sign-in
- Collaboration
- Rich formatting
- OCR, AI, or speech features
- Cross-platform support
- Guaranteed invisibility in every screen-sharing tool

## Recommended Stack

Build the first version as a native macOS app using:

- `Swift`
- `SwiftUI` for the main interface
- `AppKit` for advanced window behavior

Why this stack:

- The app is Mac-only
- The hard part is window management, not cross-platform UI
- Native macOS APIs give the cleanest access to overlay behavior
- It keeps the app lightweight and simple to ship

## User Problem

When presenting, recording, or joining a video call, users want notes visible on their own screen without constantly switching windows or looking at a second monitor.

They want:

- Notes always visible
- Minimal visual distraction
- Easy editing before or during a presentation
- Confidence that the overlay stays out of the way

## Core User Stories

### v1 User Stories

- As a presenter, I can paste notes into the app.
- As a presenter, I can keep those notes visible above other apps.
- As a presenter, I can move and resize the overlay.
- As a presenter, I can adjust opacity so the overlay is readable but unobtrusive.
- As a presenter, I can reopen the app and still see my last saved notes.

### v2 User Stories

- As a presenter, I can hide and show the overlay quickly with a keyboard shortcut.
- As a presenter, I can lock the overlay so clicks pass through to the app underneath.
- As a presenter, I can adjust text size quickly.

### v3 User Stories

- As a presenter, I can auto-scroll my notes.
- As a presenter, I can control scrolling speed.
- As a presenter, I can pause and resume scrolling quickly.

## Functional Requirements

### v1 Requirements

The first release must include:

- A single overlay window
- A text editor for plain text notes
- Paste support
- Local persistence of the last edited notes
- Draggable window
- Resizable window
- Always-on-top window behavior
- Adjustable window opacity
- Basic app quit and relaunch behavior

### v1.1 Nice-To-Have

- Font size control
- Light and dark overlay themes
- Position presets like top-right or bottom-left

### v2 Requirements

- Global hotkey to show or hide the overlay
- Click-through mode
- Quick keyboard controls for text size and opacity
- Optional minimal settings screen

### v3 Requirements

- Auto-scroll
- Speed slider
- Pause and resume control
- Reset scroll position

## Privacy And Capture Behavior

This app should be local-first and privacy-friendly.

Principles:

- No account system
- No network dependency for core features
- No telemetry in the first version
- Notes stored locally on-device only

For capture behavior, the app may attempt to reduce screen-capture visibility using native window APIs such as `NSWindow.sharingType = .none`.

Important product note:

- This behavior should be described as a best-effort privacy feature, not a universal guarantee.
- Compatibility must be tested across macOS versions and screen-sharing tools like Zoom, Google Meet, Teams, and OBS.

## Technical Requirements

### Platform

- macOS only
- Apple Silicon support required
- Intel support optional unless there is a specific reason to include it

### Development Requirements

- Xcode
- Xcode Command Line Tools
- Git

### Suggested Deployment Target

- Target a modern macOS version supported by the current Xcode release
- Choose the oldest version that still keeps development simple

If no external compatibility requirement exists, start with a recent deployment target to avoid unnecessary API workarounds.

## High-Level Architecture

Keep the architecture very small.

### Main Components

- `App`: SwiftUI app entry point
- `OverlayWindowController`: Creates and manages the floating AppKit window
- `NotesView`: SwiftUI text editing UI embedded inside the window
- `SettingsStore`: Persists notes and simple preferences
- `HotkeyManager`: Handles global shortcuts in later versions
- `AutoScrollController`: Manages scrolling behavior in later versions

### Data Model

For the first version, the model can stay extremely simple:

- `notesText: String`
- `windowOpacity: Double`
- `fontSize: Double`
- `windowFrame: CGRect` or equivalent serializable form
- `isClickThroughEnabled: Bool`

## Window Behavior Requirements

The overlay window should:

- Stay above normal app windows
- Be movable
- Be resizable
- Support transparency
- Optionally support click-through mode later
- Restore prior size and position on relaunch

The window should feel closer to a utility overlay than a traditional document app.

## UI Requirements

### v1 UI

Keep the interface minimal:

- One notes area
- One opacity control
- A clean title area or toolbar
- Optional small status controls

Recommended approach:

- Use plain text first
- Avoid heavy settings UI
- Favor keyboard-friendly interactions

### Design Direction

The UI should feel:

- Calm
- Lightweight
- Native to macOS
- Functional rather than decorative

## Persistence Requirements

For the first version, persistence can use:

- `UserDefaults` for simple preferences
- A lightweight local file for the notes body if needed

Suggested first choice:

- Use `UserDefaults` for preferences
- Store the note text in a small file or also in `UserDefaults` if size remains modest

No database is required for v1.

## Milestones

### Milestone 1: Functional MVP

Deliver:

- Native macOS app project created in Xcode
- Floating overlay window
- Editable notes area
- Save and restore note text
- Save and restore window position
- Opacity slider

Success criteria:

- User can paste notes and present with the overlay open

### Milestone 2: Presenter Controls

Deliver:

- Global show/hide shortcut
- Click-through toggle
- Font size adjustment
- Cleaner window chrome

Success criteria:

- User can leave the overlay present without it interfering with presentation controls

### Milestone 3: Auto-Scroll

Deliver:

- Auto-scroll engine
- Speed controls
- Pause and resume shortcut

Success criteria:

- User can read from the overlay hands-free during a talk

### Milestone 4: Privacy Testing

Deliver:

- Manual compatibility matrix for screen-sharing tools
- Documented behavior by macOS version and app

Success criteria:

- User understands where capture hiding works, where it fails, and what tradeoffs exist

## Risks

### Primary Technical Risk

The biggest risk is capture invisibility behavior on macOS.

Reasons:

- Behavior may vary by macOS version
- Behavior may vary by screen-sharing app
- Some recording paths may still capture the overlay

### Secondary Risks

- Global hotkeys can add implementation complexity
- Click-through mode can confuse users if there is no quick unlock path
- Auto-scroll can feel awkward without careful tuning

## Testing Plan

### v1 Testing

- Launch app
- Paste notes
- Quit and relaunch
- Confirm notes persist
- Move and resize window
- Confirm frame persists
- Adjust opacity
- Confirm overlay stays above presentation apps

### v2 Testing

- Verify global hotkeys work reliably
- Verify click-through can be toggled on and off safely
- Verify emergency recovery path if overlay becomes non-interactive

### v3 Testing

- Verify auto-scroll is smooth
- Verify speed changes are responsive
- Verify pause and resume are predictable

### Capture Testing

Test with:

- Zoom
- Google Meet in Chrome
- Microsoft Teams
- OBS
- macOS built-in screenshot and recording tools

Record results as:

- Works
- Partially works
- Does not work

## Suggested Project Structure

Once the Xcode project exists, a simple structure like this is enough:

```text
GhostNotes/
  GhostNotesApp.swift
  App/
  Window/
  Features/Notes/
  Features/Settings/
  Services/
  Models/
  Resources/
```

Suggested ownership:

- `App/`: app entry and lifecycle
- `Window/`: overlay window creation and behavior
- `Features/Notes/`: notes editor UI and state
- `Features/Settings/`: simple controls
- `Services/`: persistence, hotkeys, auto-scroll
- `Models/`: small data types

## Development Setup Checklist

Before starting:

- Install `Xcode`
- Open Xcode once and complete first-run setup
- Confirm `xcodebuild -version` works
- Confirm `xcode-select -p` points at `/Applications/Xcode.app/Contents/Developer`
- Create a new macOS app project in Xcode
- Choose `SwiftUI` for the app lifecycle
- Use Git from the start

## Initial Build Plan

### First Implementation Pass

Build only:

- A single floating window
- A text editor
- Save and restore notes
- Save and restore window frame
- Opacity slider

Do not add:

- Auto-scroll
- Global shortcuts
- Multiple note types
- Complex settings

### Second Implementation Pass

Add:

- Show and hide shortcut
- Click-through mode
- Font size control

### Third Implementation Pass

Add:

- Auto-scroll
- Speed control
- Pause and resume

## Open Questions

Before building beyond MVP, answer:

- Should the app live as a normal dock app or a menu bar utility?
- Should the notes window have standard macOS chrome or a more minimal overlay appearance?
- Is the primary use case presentations, video calls, or recordings?
- How important is screen-share invisibility versus just having a good overlay?
- Do you want plain text only, or light formatting later?

## Recommendation

Create the project as a native macOS `SwiftUI + AppKit` app and deliberately keep the first milestone tiny.

The best first deliverable is not a full “invisible teleprompter” product. It is a simple, reliable overlay notes app with local persistence and solid window behavior. Once that exists, features like auto-scroll and click-through become straightforward iterations instead of architectural bets.
