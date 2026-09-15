# Contributing to TableMacro

TableMacro is a research prototype, so the easiest contributions to review are ones
that keep the DSP test suite green and respect the four-zone design.

## Setup

You need macOS 14 or later, Xcode (26 recommended), and
[XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
brew install xcodegen
```

The Xcode project is generated from `project.yml`. After changing `project.yml`
— or adding or removing source files — regenerate it:

```sh
xcodegen generate
```

## Build and test

A non-signing command-line build is the quickest way to verify a change:

```sh
xcodebuild \
  -project TableMacro.xcodeproj \
  -scheme TableMacro \
  -configuration Debug \
  -derivedDataPath /tmp/TableMacroDerived \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Run the unit suite with the same invocation, replacing `build` with `test`.

`TableMacroCore`, `TableMacroSoak`, `TableMacroReplaySupport`, and `TableMacroReplay` have no SwiftUI or
AppKit dependency and also build with plain SwiftPM:

```sh
swift build
swift test
```

To run the app itself, use Xcode's normal **Sign to Run Locally** build. The
`CODE_SIGNING_ALLOWED=NO` bundle lacks the audio-input entitlement and should
not be launched (see the README's Build section).

## Soak runner

The synthetic DSP stress runner exercises detection, feature extraction,
classification, and rejection without the GUI or a microphone:

```sh
xcodebuild \
  -project TableMacro.xcodeproj \
  -scheme TableMacroSoak \
  -configuration Release \
  -derivedDataPath /tmp/TableMacroSoakDerived \
  CODE_SIGNING_ALLOWED=NO \
  build

DYLD_FRAMEWORK_PATH=/tmp/TableMacroSoakDerived/Build/Products/Release \
  /tmp/TableMacroSoakDerived/Build/Products/Release/TableMacroSoak --duration 1800
```

## Route check

Check the current built-in hardware routes without opening TableMacro or requesting
microphone access:

```sh
xcodebuild \
  -project TableMacro.xcodeproj \
  -scheme TableMacroRouteCheck \
  -configuration Debug \
  -derivedDataPath /tmp/TableMacroRouteDerived \
  CODE_SIGNING_ALLOWED=NO \
  build

DYLD_FRAMEWORK_PATH=/tmp/TableMacroRouteDerived/Build/Products/Debug \
  /tmp/TableMacroRouteDerived/Build/Products/Debug/TableMacroRouteCheck
```

## Offline replay

Retain evaluation feature vectors by running a new Accuracy Test in the app,
then replay its saved JSON against a freshly trained classifier:

```sh
swift run TableMacroReplay \
  --profile path/to/profile.json \
  --evaluation path/to/evaluation.json
```

Add `--json` for machine-readable output. Reports created before feature
retention show reduced coverage, and their missing attempts remain incorrect in
the replay denominator.

## Where things live

- `Sources/TableMacroCore` — the detection engine: streaming detector, impact gate,
  FFT and feature extraction, classifier, persistence models, diagnostics, and
  evaluation reporting. No SwiftUI dependency. Covered by `Tests/TableMacroCoreTests`.
- `Sources/TableMacroApp` — audio capture, app state, local action dispatch, and the
  SwiftUI interface.
- `Sources/TableMacroSoak`, `Sources/TableMacroReplay`, and `Sources/TableMacroRouteCheck` —
  non-GUI verification tools.

## Notes for pull requests

- Keep changes small, and run the unit suite before opening a PR.
- The four-zone topology is intentional. Six- and nine-zone layouts were tried
  and abandoned, so PRs should not reopen that decision.
- DSP changes should preserve the behavior pinned by `Tests/TableMacroCoreTests`
  unless the PR is explicitly about changing that behavior.
