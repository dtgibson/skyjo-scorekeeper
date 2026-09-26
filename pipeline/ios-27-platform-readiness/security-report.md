# Security Review — iOS 27 Platform Readiness

**Date:** 2026-09-26
**Feature:** ios-27-platform-readiness (Improve lane, design pass)
**Stack:** frontend `swiftui` / backend `none` (local-only, no network, no auth, no accounts)
**Checklist:** None. This stack has no dedicated checklist. `swiftui` is not in the frontend table and backend is `none`. Following the unmapped-stack fallback, I ran four passes instead:
1. A local data and input pass based on OWASP MASVS: STORAGE, CODE, PLATFORM and PRIVACY. NETWORK, AUTH and CRYPTO don't apply because the app has none of those surfaces.
2. A two-window state-integrity pass.
3. A platform-surface pass covering entitlements, Info.plist and the privacy manifest.
4. A CI supply-chain pass using GitHub Actions hardening guidance and the OWASP Top 10 CI/CD Security Risks.

No other stack checklist was loaded. The Supabase, FastAPI, Vercel Edge and web checklists cover surfaces this app doesn't have.

**Verification tier:** 2 — Full weave (from `weft-scope classify`: classes `logic, security-surface`, trigger `ci-deploy`; this was the floor and needed no escalation)
**Outcome:** PASSED WITH NOTES

---

## Deterministic scan floor

`weft-scope scan` → `SCAN-RESULT findings=2 tool=grep`

| Scan note | Triage |
|---|---|
| `trust-boundary-touch` — `SkyjoScorekeeper/Models/GameSession.swift` | Audited in full (see State integrity checks). The only change is a 4-line guard at the top of `commitRound` (line 89) that ignores new rounds after the game is over. It narrows behavior. It adds no storage, network or input path. |
| `trust-boundary-touch` — `SkyjoScorekeeperTests/GameSessionTests.swift` | Audited. It adds 1 model test and 3 layout tests. It adds no fixture files, secrets or new disk writes beyond the existing `makeSession` pattern. |

The scan found no secrets and no dangerous patterns. I also grepped every added line for logging calls, networking, storage APIs, pasteboard, `openURL`, token or password strings, and `${{` workflow interpolation. Nothing matched.

---

## Summary

This build adds no new attack surface and changes no trust boundary.
- The saved-game format, `SessionStore`, the app's restore path, the privacy manifest and the Xcode project are all byte-for-byte unchanged.
- No new data is written anywhere.
- The one model change makes things safer: `commitRound` now refuses rounds after the game is over. This closes a pre-existing gap where a second window could record scores into a finished game.
- The CI move to `runs-on: xcode-27` targets a genuine GitHub-hosted runner, not a self-hosted one.

Two small CI hardening notes predate this build. Both are non-blocking and listed below.

---

## Findings

### F1 — Workflow doesn't declare its token permissions

**Severity:** Low (pre-existing, not introduced by this build)
**Location:** `.github/workflows/pipeline.yml`, top level (lines 1–9; no `permissions:` key)
**Description:** The workflow sets no `permissions:` block, so the `GITHUB_TOKEN` gets whatever the repository default is.
- The default today is read-only (`default_workflow_permissions: "read"`, confirmed via the GitHub API).
- Fork pull requests always get a read-only token.
- So the effective risk is low right now.

The protection lives in a repo setting, though, not in the file. If that setting were ever flipped to read/write, every job would silently gain write access to the repo. Those jobs run `xcodebuild` on code from pushes and pull requests.
**Remediation:** Add this at the top level of the workflow, after `on:`:
```yaml
permissions:
  contents: read
```
Nothing in the workflow needs more than that.
**Status:** Open (non-blocking; accepted for this build)

### F2 — Checkout action pinned by tag, and credentials kept on disk

**Severity:** Informational (pre-existing, not introduced by this build)
**Location:** `.github/workflows/pipeline.yml:15` — `- uses: actions/checkout@v5`
**Description:** The workflow has two small hygiene gaps:
- **Tag pinning.** The only action used is GitHub's own `actions/checkout`, referenced by the mutable major tag `v5` rather than a commit SHA. First-party actions are low risk. SHA-pinning is still the hardening baseline, because a moved tag changes what runs without any change to this file.
- **Persisted credentials.** `persist-credentials` is left at its default (`true`), so the job token stays in `.git/config` for the later build steps. None of those steps push or need git auth.

**Remediation:** Pin to the full commit SHA of the current v5 release, with a version comment (e.g. `actions/checkout@<sha> # v5.x.y`). Add `with: { persist-credentials: false }`.
**Status:** Open (non-blocking; accepted for this build)

---

## Checks Performed

### Data at rest (MASVS-STORAGE)

| Check | Result |
|---|---|
| Persisted snapshot shape unchanged: `GameSessionSnapshot`, `Player`, `Round`, `RoundScore` have no diff against `383fa53` | Pass |
| `schemaVersion` / `GameSessionSnapshot.currentVersion` unchanged (1), so no migration is needed and old saves still decode | Pass |
| `SessionStore` unchanged: same file (`Application Support/active-game.json`), atomic write, silent failure | Pass |
| No new data written. Added lines contain no `AppStorage`, `SceneStorage`, `UserDefaults`, `FileManager`, `NSUserActivity`, or encoder/decoder. The new `LayoutMode` value is transient view `@State` and is never persisted | Pass |
| Save/clear semantics on commit. The new guard returns before any save or clear. The file of a finished game (already cleared on the ending round) stays cleared, and a stale finished-game snapshot can't be re-saved | Pass |
| Launch restore path (`SkyjoScorekeeperApp.init`) unchanged. It still refuses to restore a finished game | Pass |

### Input handling (MASVS-CODE)

| Check | Result |
|---|---|
| Score entry is capped at 3 digits (`ScoreEntrySheet.swift:317`, unchanged). The largest value is 999, or 1998 when doubled, so `raw * 2` in `commitRound` can't overflow and trap | Pass |
| Parsing uses `Int(text)`, with a `nil` fallback for anything non-numeric. Confirm is gated on every row being filled and a round-ender being chosen (unchanged) | Pass |
| The layout refactor keeps one copy of entry state (`rawInputs`, `negativeInputs`, `skyjoPlayerID`, `focusedPlayer`) at the sheet level, shared by the stacked and side-by-side layouts. Switching layouts can't desync what's shown from what's committed | Pass |
| `LayoutMode(size:)` guards non-positive sizes before dividing, so there's no divide-by-zero or NaN mode. `onAvailableSize` also skips zero readings | Pass |
| `fittedPanelHeight(playerCount:)` clamps with `max(playerCount, 1)`, so it's safe for zero players | Pass |

### State integrity across two windows

| Check | Result |
|---|---|
| `commitRound` ignores rounds once `isGameOver` (`GameSession.swift:89`), so a second window's open entry sheet can't add scores to a finished game. Covered by `testCommitRoundIgnoredAfterGameOver` | Pass |
| The guard can't drop rounds from a live game. `isGameOver` logic is unchanged, and the only caller is the entry sheet's commit closure (`ScoringView.swift:70`) | Pass |
| The entry sheet presentation is derived from the shared session (`showEntrySheet && !session.isGameOver`), so it closes in every window when the game ends | Pass |
| The win screen presentation is derived from `session.isGameOver` and has a no-op setter. Its only exits are `onNewGame`, which change the shared `route` on the `App`. The user can't get stranded, and no window keeps a stale scoreboard | Pass |
| Undo after game over: `undoLastRound` has no game-over guard of its own. It's unreachable, though, because the toolbar sits under the full-screen win cover in every window. Even if it were reached, it would save a valid in-progress snapshot, not a corrupt one | Pass (note) |
| Both New Game paths still clear the saved state (`GameSession(players:)` and the `App`'s `onNewGame` closure) | Pass |

### Platform surface (MASVS-PLATFORM / MASVS-PRIVACY)

| Check | Result |
|---|---|
| No new entitlements or capabilities. The repo has no `.entitlements` files, and `SkyjoScorekeeper.xcodeproj` has no diff | Pass |
| No Info.plist or build-setting change (the project file is unchanged; multiple-scene support was already on) | Pass |
| `PrivacyInfo.xcprivacy` unchanged. No required-reason APIs were added | Pass |
| No network, URL handling, deep links, pasteboard or share-sheet code added | Pass |
| No logging or debug output of user data (no `print`, `NSLog`, `os_log`, `Logger` or `dump` in added lines) | Pass |
| VoiceOver announcements: content unchanged (a player name and total, spoken on-device only) | Pass |
| No secrets, keys or tokens anywhere in the diff | Pass |

### CI supply chain (`.github/workflows/pipeline.yml`)

| Check | Result |
|---|---|
| `runs-on: xcode-27` is a GitHub-hosted label. The `actions/runner-images` README lists the "Xcode 27" image (arm64, preview) under the label `xcode-27`. It doesn't fall through to a self-hosted runner. The repo is public but has 0 self-hosted runners (API), and the owner is a user account, so there are no org runners | Pass |
| The image is a public preview with no stability guarantee. That's an availability concern, not a security one. The `macos-26` fallback is documented in the file | Pass (note) |
| Triggers unchanged: `push` and `pull_request` on `main`. There's no `pull_request_target` or `workflow_run`, so fork code never runs with elevated tokens or secrets | Pass |
| No secrets referenced | Pass |
| No script injection: no `${{ github.event.* }}` or other untrusted context is interpolated into `run:` | Pass |
| Token permissions declared explicitly | Finding — F1 (Low, pre-existing) |
| Third-party actions pinned. The only action is first-party `actions/checkout@v5`, tag-pinned with persisted credentials | Finding — F2 (Informational, pre-existing) |
| CI outputs can't reach users. Code signing is disabled, the Release build is simulator-only, and nothing is uploaded or published | Pass |
| Destination change from `iPhone 16` to `iPhone 17` has no security impact | Pass |

### Tests

| Check | Result |
|---|---|
| `GameSessionTests.swift` adds tests only (1 model, 3 layout). No fixtures, secrets or new disk writes | Pass |

---

## Convention Flags

- **Guard rules that must hold for a finished game in the model, not only in the UI.** All open windows share one `GameSession`, so a UI-only guard (like the old single-window `showWinView`) isn't enough. `commitRound` now does this. Any future mutation that shouldn't apply after game over should do the same.
- **Harden the CI workflow as a standing rule.** Declare `permissions: contents: read` explicitly, pin actions by commit SHA with a version comment, and set `persist-credentials: false` on checkout unless a later step needs git auth.
