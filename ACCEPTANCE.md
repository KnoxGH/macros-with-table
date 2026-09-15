# TableMacro acceptance audit

The current topology is four broad zones: rear and front on the left of the MacBook, and rear and front on the right. Evaluation is balanced at 15 held-out taps per zone, 60 total.

## Evidence status

| Requirement | Current evidence | Status |
| --- | --- | --- |
| Native macOS MVP | `TableMacro` builds as a sandboxed, single-window SwiftUI macOS application targeting macOS 14+. Closing its only window terminates capture with the app. | Design and source verified |
| Built-in MacBook audio only | Core Audio default-route IDs and transport types are checked before capture. External inputs are rejected; Active/Hybrid also reject external output. Policy tests cover valid and invalid routes. | Automated policy verified |
| Four desk zones | The model contains exactly LR, LF, RR, and RF. Topology and session-order tests pin rear and front zones to each side. | Automated verified |
| Native anti-slop interface | Standard macOS navigation, lists, forms, tables, toolbars, and controls are used. The desk is two continuous two-zone rails around a MacBook silhouette rather than four card tiles; Liquid Glass is limited to functional primary controls on macOS 26. | Source verified; visual review pending |
| Diagnostic recorder | Diagnostics reports selected input/output routes and built-in status, exposed channels, sample rate, buffer timing/jitter, frequency response, signal quality, and labeled feature captures. | Implemented; live capture output pending |
| Passive versus active sensing | Passive, active-probe, and hybrid feature schemas are implemented. A 36-sample guided comparison measures cross-validation accuracy and latency, and selection logic is tested. Results are profile-scoped, and an injected-chirp regression verifies active correlation and delay recovery. | Automated logic verified; physical comparison pending |
| Guided calibration | Ten spatially varied taps per zone after explicit setup consent, automatic disarmed transitions between zones, visible re-arm fallback, actionable weak/noisy/clipped retry guidance, undo, zone redo, recommended Talking negatives plus other optional negatives, and weakest-zone consistency review. | Protocol and quality policy automated; physical workflow pending |
| Reusable desk profile | Feature-only versioned JSON stores the trained classifier, desk/laptop notes, and four actions. Legacy six-zone and nine-zone files are skipped by version before zone decoding; current files are checked for four-zone classifier structure and matching calibration counts. Malformed files, initialization failures, and write failures are surfaced instead of reporting false success. | Persistence automated |
| Real-time recognition path | Streaming onset detection, 90 ms capture, a full-event sustained-sound gate, one shared spectrum analysis, regularized linear zone scoring, nearest-example novelty/negative checks, and confidence gates are connected. Capture generations discard observations queued before a stop or strategy change. A synthetic chunked pipeline test covers all four zones. | Synthetic integration verified; live input pending |
| Configurable local actions | Visual-only, system sound, copy text, speech, HTTP(S), user-named Shortcut, user-selected application or item, shell command, and full or selected screenshot actions are implemented. New zones are visual-only by default. Automatic side effects run only on Desk, not while editing or running guided workflows. A shared validated planner drives both inline Test and live taps. Shell commands are clearly labeled as automatic and run with TableMacro's sandbox permissions. | Planning and persistence verified; OS invocation smoke test pending |
| False-trigger rejection | Weak, noisy, clipped, OOD, schema-mismatched, calibrated-negative, and meaningfully ambiguous observations are rejected. Onset learns the room for 0.75 seconds and requires a brief impact; complete candidates with sustained speech-like duration and energy are dropped before classification. Deterministic regressions reject a plosive-plus-voiced speech candidate and elevated background while preserving short and resonant taps. Talking can also be captured as a profile-specific negative. The active probe is filtered out of onset detection. | Automated verified; representative live conversation pending |
| Local processing and privacy | Signal processing is local. Raw audio is discarded unless debug capture is explicitly enabled; retained WAVs remain visible and deletable after relaunch. | Source and persistence verified; runtime privacy observation pending |
| Immediate pause and recalibration | Toolbar pause stops input/probe and disarms guided capture. Pause remains sticky. Recalibration preserves existing actions. | Source verified; runtime interaction pending |
| Balanced 60-tap evaluation | Accuracy Test enforces 15 taps for each of four zones. Rejections count as incorrect. | Protocol automated; physical session pending |
| Per-zone output and confusion matrix | JSON/CSV and UI reporting include overall/per-zone accuracy, four-by-four confusion matrix, rejected counts, confidence, and latency. Saved history is restored only for its profile and topology, and save failures are labeled memory-only. | Automated verified |
| At least 80% physical accuracy | No real held-out report exists yet for any target MacBook and desk. | Pending — no claim made |
| Median response below 200 ms | Response latency is mapped from each audio buffer's monotonic `AVAudioTime` host timestamp through feature extraction, main-thread delivery, and classification, with sample-offset and elapsed-time regression coverage. Invalid timing is never converted to zero and prevents the latency gate from passing. No real 60-tap report exists yet. | Instrumentation automated; physical result pending |
| Continuous 30-minute stability | `TableMacroSoak` exercises the DSP path with an accelerated mixed four-zone synthetic run and reports resident-memory growth. It does not exercise AVAudioEngine, permissions, UI, or actions. | Synthetic tooling in place; live soak pending |
| Automated core tests | `Tests/TableMacroCoreTests`, `Tests/TableMacroAppTests`, and `Tests/TableMacroReplayTests` cover the detector, classifier, persistence, evaluation reporting, guided sessions, and replay scoring. | Present; run on each change |
| Documentation | README covers build/setup, calibration, architecture, evaluation, surfaces, privacy, limitations, and how to run the automated checks. | Verified |

## Remaining completion gates

The MVP must not be called physically validated until all of the following are captured on the target MacBook and desk:

1. A passive/active/hybrid comparison using real taps.
2. A fresh four-zone calibration in the final laptop position.
3. A balanced 60-tap held-out report with at least 80% accuracy and median response below 200 ms.
4. A 30-minute live microphone/action run including taps, conversation, typing, laptop touches, and representative background noise.
5. A visual interaction review of every screen at normal and minimum window sizes.

Until those physical checks are complete, treat TableMacro as functional experimental software rather than a validated acoustic input device.
