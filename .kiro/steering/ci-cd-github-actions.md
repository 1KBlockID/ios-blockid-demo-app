---
inclusion: fileMatch
fileMatchPattern: ['.github/workflows/**', 'Scripts/ci/**']
---

# iOS Demo App CI/CD — GitHub Actions

This document describes the CI/CD pipeline for building and distributing the 1Kosmos Demo iOS app. Use it when modifying workflow files, export options plists, or CI scripts.

## Key Files

- Workflow: `#[[file:.github/workflows/build-and-distribute.yml]]`
- Export options: `#[[file:Scripts/ci/export_options.plist]]`

## App Details

| Property | Value |
|---|---|
| App Name | 1Kosmos Demo |
| Scheme | `1Kosmos Demo` |
| Workspace | `BlockIDTestApp.xcworkspace` |
| Bundle ID | `com.onekosmos.blockid.poc` |
| Entitlements | `1Kosmos DemoRelease.entitlements` |
| Info.plist | `BlockIDTestApp/Info.plist` |
| Team ID | `WUS4823E84` |

## Workflow Architecture

### Triggers
- Push to `master` or `release` builds the app.
- `workflow_dispatch` allows manual trigger.

### Steps
1. Checkout & setup environment
2. Resolve SPM dependencies
3. Install signing certificate & provisioning profile
4. Stamp build number (epoch seconds)
5. Archive (unsigned)
6. Sign archive with entitlements
7. Export IPA
8. Rename artifacts (`1KosmosDemo_{VERSION}_{BUILD_VERSION}`)
9. Upload to Firebase App Distribution (direct REST API)
10. Create version tag on repo
11. Upload IPA + xcarchive artifacts

### Concurrency
Uses `group: ${{ github.workflow }}-${{ github.ref }}` with `cancel-in-progress: true`.

## Pinned Versions

| Tool | Env var / Location | Current value |
|---|---|---|
| Xcode | `XCODE_VERSION` | `26.0.1` |
| Ruby | hardcoded in `setup-ruby` | `3.2` |

## Build & Signing Details

- Archive uses `CODE_SIGNING_REQUIRED=NO` and `CODE_SIGNING_ALLOWED=NO` — the binary is built unsigned.
- After archive, a "Sign archive with entitlements" step manually codesigns frameworks (inside-out) then the main app with `1Kosmos DemoRelease.entitlements`.
- Export options plist uses `release-testing` distribution method, manual signing style, `Apple Distribution` certificate, team ID `WUS4823E84`.
- Includes `generateEntitlementsDerivedFromProfileForSigning: true`.
- A per-run keychain (`$RUNNER_TEMP/app-signing.keychain-db`) is created, used, and deleted in an `always()` cleanup step.
- `CFBundleVersion` is stamped with epoch seconds before archive.

## Firebase App Distribution

- Uses **direct Firebase REST API** (`firebaseappdistribution.googleapis.com`) — no `firebase-tools` CLI needed.
- Authentication flow:
  1. Service account JSON written to `$RUNNER_TEMP/firebase-sa.json` from GitHub Secret
  2. SA JSON validated (checks `private_key` and `client_email` fields present)
  3. `google-auth-library` (npm) generates a short-lived OAuth2 access token via Node.js
  4. Binary uploaded via raw upload protocol (`releases:upload`)
  5. Operation polled until release is processed (up to 30 attempts, 5s apart)
  6. Release notes attached via PATCH
  7. Distributed to tester groups via POST
- Docker-based GitHub Actions (like `wzieba/Firebase-Distribution-Github-Action`) do NOT work on macOS runners.
- Distribution groups: `1Kosmos-mobile-iOS`, `1k-qa`.
- Release notes include build number, scheme, branch, commit SHA, and actor.

## Version Tagging

After successful distribution, the workflow creates and pushes a git tag:
- Format: `demo_app_{VERSION}-{BRANCH_PREFIX}.rc{NN}`
- Branch prefix: `m` for master, `r` for release
- RC number is auto-incremented based on existing tags
- Example: `demo_app_1.30.40-m.rc01`

## Caching & Artifacts

- After export, artifacts are renamed to `1KosmosDemo_{VERSION}_{BUILD_VERSION}` format (e.g. `1KosmosDemo_1.30.40_1782738648`).
- IPA uploaded as artifact with `.ipa` extension in name, 14-day retention.
- xcarchive uploaded as artifact with `.xcarchive` extension in name, 14-day retention.
- Using dot (`.`) in artifact names ensures correct file extension after download+unzip on macOS.

## Required GitHub Secrets

### Signing
| Secret | Purpose |
|---|---|
| `P12_CERTIFICATE_BASE64` | Base64-encoded `.p12` distribution certificate |
| `P12_PASSWORD` | Password for the `.p12` |
| `DEMO_APP_PROVISION_PROFILE_BASE64` | Ad-hoc profile for demo app |

### Firebase
| Secret | Purpose |
|---|---|
| `FB_APP_ID_DEMO_IOS` | Firebase App ID for demo app |
| `FIREBASE_DEMO_SERVICE_ACCOUNT_JSON` | Service account JSON for demo Firebase project |

### Encoding secrets for upload

```bash
base64 -i Certificates.p12 | pbcopy
base64 -i profile.mobileprovision | pbcopy
```

## SPM Dependencies

The demo app resolves all dependencies (BlockID SDK, Firebase, Toast) via Swift Package Manager in a dedicated step:
```yaml
- name: Resolve SPM dependencies
  run: xcodebuild -resolvePackageDependencies -workspace "$WORKSPACE" -scheme "$SCHEME"
```

## Rules for Modifying CI Files

- Do not change the archive signing flags (`CODE_SIGNING_REQUIRED=NO`, `CODE_SIGNING_ALLOWED=NO`).
- Keep the keychain cleanup step `if: always()`.
- Always use `set -o pipefail` when piping `xcodebuild` through `xcpretty`.
- When updating the provisioning profile, update both the export options plist and the `DEMO_APP_PROVISION_PROFILE_BASE64` GitHub secret.
- The Firebase upload uses direct REST API calls — no `firebase-tools` CLI is needed or should be added.
- Token generation uses `google-auth-library` npm package with `cloud-platform` scope.
- The `--token` deprecation warning from firebase-tools does NOT apply here since we don't use firebase-tools.
