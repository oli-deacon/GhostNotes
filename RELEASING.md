# Releasing GhostNotes

This project can be shared with the team without paying for Apple Developer signing.

What you get:
- an unsigned `GhostNotes.app`
- a GitHub-ready zip file
- a short install flow for teammates

## Local release steps

From the repo root:

```bash
./scripts/build-release-zip.sh
```

That creates:

```text
dist/GhostNotes-mac.zip
```

## Publish on GitHub

1. Push your latest changes to `main`.
2. Create a tag:

```bash
git tag v0.1.0
git push origin v0.1.0
```

3. Either:
- let the GitHub Action build and attach the zip to the release for that tag
- or create a GitHub Release manually and upload `dist/GhostNotes-mac.zip`

## What teammates do

1. Download `GhostNotes-mac.zip` from GitHub Releases.
2. Unzip it.
3. Move `GhostNotes.app` to `/Applications`.
4. If macOS blocks it, right-click `GhostNotes.app` and choose `Open`.
5. If needed, go to `System Settings > Privacy & Security` and allow it.

## Notes

- This app is unsigned for distribution, so Gatekeeper warnings are expected.
- The build script disables code signing so it works on machines and CI without Apple Developer certificates.
- If you want a release with fewer warnings later, the next step would be Developer ID signing and notarization.
