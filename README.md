# GhostNotes

GhostNotes is a lightweight floating presenter notes app for macOS.

## Screen Sharing Behavior

GhostNotes includes a `Hide on Share` setting that asks macOS to exclude the notes window from screen sharing and recording by setting `NSWindow.sharingType = .none`.

This is a best-effort privacy feature, not a guarantee.

- Behavior can vary by macOS version.
- Behavior can vary by capture tool, including Zoom, Microsoft Teams, and built-in macOS recording.
- Recent conferencing and ScreenCaptureKit-based display sharing can still capture GhostNotes even when screenshots do not.
- If you share one display and keep notes on another, turn off `All Spaces` so GhostNotes stays on the private display instead of following every space.
- Test your own presentation setup before relying on it live.

## Get the Latest Build

Download the latest release here:

[https://github.com/oli-deacon/GhostNotes/releases/latest](https://github.com/oli-deacon/GhostNotes/releases/latest)

## Install GhostNotes

1. Download `GhostNotes-mac.zip` from the latest GitHub release.
2. Unzip the file.
3. Drag `GhostNotes.app` into your `/Applications` folder.
4. Open `GhostNotes`.

## If macOS Blocks the App

Because this is an internal unsigned app, the first-launch warning is expected.

Try this:

1. Right-click `GhostNotes.app`.
2. Choose `Open`.
3. Click `Open` again in the warning dialog.

If needed:

1. Open `System Settings > Privacy & Security`.
2. Allow `GhostNotes` to run.

## Optional Terminal Fix

If macOS still refuses to open the app after download, run:

```bash
xattr -dr com.apple.quarantine /Applications/GhostNotes.app
```

Then try opening the app again.

## Releasing

Internal release packaging notes for maintainers live in [RELEASING.md](/Users/olideacon/code/GhostNotes/RELEASING.md).
