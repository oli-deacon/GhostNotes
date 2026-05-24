# GhostNotes

GhostNotes is a lightweight floating presenter notes app for macOS.

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
