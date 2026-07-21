# Debugging the BlockID SDK Source from the Demo App

This guide explains how to run **`ios-blockid-demo-app`** against the **`ios-kernel-sdk`** source
(the actual SDK code) instead of the prebuilt `BlockID.xcframework`. With this setup you can edit
SDK code, set breakpoints, and just hit **Run** — no need to rebuild the xcframework (`build.sh`)
each time.

## Prerequisites
- Xcode 15+ (matching the team's version).
- Both repos checked out **side by side** under the same parent folder:
  ```
  <parent>/
    ├── ios-blockid-demo-app/
    └── ios-kernel-sdk/
  ```
  The relative path `../ios-kernel-sdk/BlockID.xcodeproj` is used, so this layout matters.
- CocoaPods installed (the app uses Pods for Firebase/Toast).

## Background: how it's wired
- The app normally consumes the SDK via a **remote Swift Package** (`ios-blockidsdk`) that just
  wraps a prebuilt `BlockID.xcframework`.
- `ios-kernel-sdk/BlockID.xcodeproj` is the SDK **source**; it has a framework target/scheme named
  `BlockID` and builds against these Swift packages: `OpenSSL`, `Alamofire`, `CryptoSwift`,
  `BigInt`, `wallet-core`.
- To debug live, we replace the prebuilt package with the source project inside one workspace.

---

## One-time setup (Xcode UI)

1. **Open the workspace** (always the workspace, never the bare `.xcodeproj`, because of CocoaPods):
   `ios-blockid-demo-app/BlockIDTestApp.xcworkspace`

2. **Add the SDK source project to the workspace.**
   Drag `ios-kernel-sdk/BlockID.xcodeproj` from Finder into the Project navigator, dropping it at
   the **root** level (a sibling of `BlockIDTestApp` and `Pods` — *not* nested inside the app
   project).

3. **Remove the prebuilt SPM dependency.**
   - Select the app project → target **`1Kosmos Demo`** → **General** →
     *Frameworks, Libraries, and Embedded Content* → select the `BlockID` entry that comes from the
     `ios-blockidsdk` package and click **–**.
   - Project → **Package Dependencies** → remove the `ios-blockidsdk` remote package.

4. **Link the source-built framework.**
   In *Frameworks, Libraries, and Embedded Content* → **+** → choose `BlockID.framework` listed
   under the `BlockID` (ios-kernel-sdk) subproject → set it to **Embed & Sign**.

5. **Embed the SDK's dynamic dependencies (important — see note below).**
   Add these Swift Package **products** to the `1Kosmos Demo` target
   (*Frameworks, Libraries, and Embedded Content* → **+** → *Add Package Dependency* if needed, or
   pick from the resolved packages), using the SDK's exact pins:
   | Package | Repo | Version | Product(s) |
   |---|---|---|---|
   | OpenSSL | `github.com/krzyzanowskim/OpenSSL.git` | exact `3.3.3001` | `OpenSSL` |
   | wallet-core | `github.com/trustwallet/wallet-core.git` | exact `4.6.13` | `WalletCore`, `WalletCoreSwiftProtobuf` |

   Xcode auto-embeds dynamic Swift Package products into the app, which is what dyld needs at launch.

6. **For faster debug builds (optional but recommended):**
   Select the `BlockID` target → Build Settings → set **Build Libraries for Distribution = NO**.
   (`build.sh` only needs `YES` when producing the distributable xcframework.)

7. **Build & Run** (`⌘R`). Let Xcode resolve the packages the first time (needs network).

---

## Why step 5 matters (the launch crash)
The source-built `BlockID.framework` links three **dynamic** frameworks via `@rpath`:
`WalletCore`, `OpenSSL`, and `SwiftProtobuf` (the latter comes from `WalletCoreSwiftProtobuf`).

The old `ios-blockidsdk` package embedded these automatically. When you link the raw framework
without embedding them, the app builds fine but **aborts at launch (SIGABRT)** with a
`dyld: Library not loaded: @rpath/WalletCore.framework/...` style error. Adding those package
products to the app target (step 5) fixes it.

`Alamofire`, `CryptoSwift`, and `BigInt` are statically baked into `BlockID.framework`, so they do
**not** need to be added separately.

---

## Verifying you're on source (not the binary)
- After building, Cmd-click a BlockID symbol in the app — it should jump into the `.swift` source in
  `ios-kernel-sdk`, not a generated `.swiftinterface`.
- In the build log you should see the `BlockID` target compiling.
- Set a breakpoint in, e.g., `ios-kernel-sdk/BlockIDSDK/BIDAPIs/Internal/BIDNetworkManager.swift` and
  confirm it hits during a network call.

## Daily workflow
1. Edit SDK code in `ios-kernel-sdk`.
2. `⌘R` in the demo app workspace — the framework recompiles from source automatically.
3. Debug with breakpoints as if it were app code.

## Troubleshooting
- **`dyld: Library not loaded: @rpath/...` at launch** → step 5 not done (or missing one product).
- **Package resolution errors** → File > Packages > Reset Package Caches, then Resolve. Ensure the
  versions match the SDK's exact pins.
- **Simulator arch errors on Apple Silicon** → prefer a real device, or check that
  `EXCLUDED_ARCHS[sdk=iphonesimulator*]` isn't forcing out `arm64`.
- **Stale build after switching** → Clean Build Folder (`⇧⌘K`) and rebuild.

## Reverting to the prebuilt SDK
Undo the changes to `BlockIDTestApp.xcodeproj` and the workspace (e.g., `git checkout` those files),
which restores the `ios-blockidsdk` remote package.
