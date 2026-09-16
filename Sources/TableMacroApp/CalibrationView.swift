import TableMacroCore
import SwiftUI

struct CalibrationView: View {
    @ObservedObject var model: AppModel
    @State private var showRejectionTraining = true

    var body: some View {
        Group {
            if let session = model.calibrationSession {
                activeCalibration(session)
            } else {
                setup
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(TableMacroTheme.background)
    }

    private var setup: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Set up your table")
                    .font(.tablemacroTitle(28))
                Text("Ten clean taps in each of four broad spots. Spread them around each highlighted area so TableMacro learns the whole spot, not one point.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Form {
                Section("Profile") {
                    TextField("Name", text: $model.calibrationDraft.name, prompt: Text("My Table"))
                    TextField("Surface", text: $model.calibrationDraft.surfaceDescription, prompt: Text("Wood, laminate, glass…"))
                    TextField("MacBook position", text: $model.calibrationDraft.laptopPositionNote, prompt: Text("Centered, near the back edge…"))
                }

                Section("Sensing") {
                    Picker("Approach", selection: $model.calibrationDraft.strategy) {
                        ForEach(SensingStrategy.allCases) { strategy in
                            Text(strategy.displayName).tag(strategy)
                        }
                    }
                    Text(model.calibrationDraft.strategy.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if model.calibrationDraft.strategy != .passive {
                        Label("Uses a quiet repeating speaker chirp", systemImage: "speaker.wave.2")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Before training") {
                    Label("Put the MacBook where it normally stays", systemImage: "macbook")
                    Label("Clear objects and cables that touch the MacBook", systemImage: "rectangle.dashed")
                    Label("Use one finger and a similar natural force, but vary the position within each spot", systemImage: "hand.tap")
                }

                Section {
                    if let comparison = model.applicableApproachComparison {
                        Label(
                            "The latest Signal Lab comparison selected \(comparison.selectedStrategy.displayName).",
                            systemImage: "checkmark.circle"
                        )
                    } else {
                        Label(
                            model.selectedProfile == nil
                                ? "Passive sensing is selected until you compare approaches in Signal Lab."
                                : "This profile keeps its saved approach until you compare approaches on this table.",
                            systemImage: "info.circle"
                        )
                    }

                    HStack {
                        if let profile = model.selectedProfile {
                            Button("Retrain \(profile.name)") {
                                model.beginCalibration(draft: model.calibrationDraft, recalibrating: profile)
                            }
                            .tablemacroPrimaryButton()
                            .controlSize(.large)

                            Button("Create New Profile") {
                                model.beginCalibration(draft: model.calibrationDraft)
                            }
                            .tablemacroSecondaryButton()
                        } else {
                            Button("Begin Training") {
                                model.beginCalibration(draft: model.calibrationDraft)
                            }
                            .tablemacroPrimaryButton()
                            .controlSize(.large)
                        }
                    }
                    .disabled(model.calibrationDraft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .formStyle(.grouped)
        }
        .frame(maxWidth: 680, alignment: .leading)
        .padding(36)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func activeCalibration(_ session: CalibrationSession) -> some View {
        ScrollView {
            VStack(spacing: 22) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(session.zonesComplete ? "All spots captured" : session.currentZone?.displayName ?? "Training")
                            .font(.tablemacroTitle(26))
                            .foregroundStyle(session.currentZone.map(TableMacroTheme.color(for:)) ?? TableMacroTheme.accent)
                        Text(session.zonesComplete ? "Save the profile, then assign macros." : instruction(for: session))
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(session.positiveSamples.count) of \(session.totalRequired)")
                        .font(.callout.monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                ProgressView(value: session.progress)
                    .accessibilityLabel("Training progress")

                DeskMapView(
                    activeZone: nil,
                    targetZone: session.currentZone,
                    confidence: 0,
                    signalStrength: model.audio.liveLevel,
                    isListening: model.audio.isListening,
                    counts: DeskZone.allCases.map { session.count(for: $0) }
                )
                .frame(maxWidth: 760)

                if session.zonesComplete {
                    completionControls(session)
                } else {
                    zoneControls(session)
                }
            }
            .frame(maxWidth: 820)
            .padding(32)
            .frame(maxWidth: .infinity)
        }
    }

    private func zoneControls(_ session: CalibrationSession) -> some View {
        VStack(spacing: 14) {
            if session.isSettling {
                HStack(spacing: 9) {
                    ProgressView()
                        .controlSize(.small)
                    Text(settlingMessage(for: session))
                        .font(.headline)
                }
                .accessibilityElement(children: .combine)
            } else if session.isArmed {
                HStack(spacing: 8) {
                    Circle()
                        .fill(.red)
                        .frame(width: 7, height: 7)
                    Text("Listening for this spot")
                        .font(.headline)
                    if let zone = session.currentZone {
                        Text("Tap \(session.count(for: zone) + 1) of \(session.targetPerZone)")
                            .font(.callout.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityElement(children: .combine)
            } else if let zone = session.currentZone {
                Text("Move your hand to the \(zone.displayName.lowercased()) area. TableMacro ignores all sounds until you arm the spot.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Arm \(zone.displayName)") {
                    model.armCalibrationZone()
                }
                .tablemacroPrimaryButton()
                .controlSize(.large)
                .disabled(!model.audio.isListening)
                .help(model.audio.isListening ? "Start collecting this spot" : "Resume the microphone before arming")
                .accessibilityHint(model.audio.isListening
                    ? "Starts listening for taps in this spot."
                    : "The microphone is paused. Resume it before arming.")
            }

            if let issue = model.guidedCaptureIssue {
                Label(issue.guidance, systemImage: "arrow.counterclockwise.circle")
                    .font(.callout)
                    .foregroundStyle(.orange)
                    .multilineTextAlignment(.center)
                    .accessibilityLabel("Capture guidance: \(issue.guidance)")
            } else if let quality = model.audio.diagnostics.latestSignalQuality {
                HStack(spacing: 18) {
                    Label(quality.summary, systemImage: quality.score > 0.48 ? "checkmark.circle" : "exclamationmark.circle")
                    Text(String(format: "%.1f dB SNR", quality.signalToNoiseDB))
                    Text(String(format: "%.3f peak", quality.peakAmplitude))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Signal quality")
                .accessibilityValue("\(quality.summary). \(String(format: "%.1f", quality.signalToNoiseDB)) decibels signal to noise.")
            }

            HStack {
                Button("Undo", systemImage: "arrow.uturn.backward") {
                    model.undoLastCalibrationTap()
                }
                .tablemacroSecondaryButton()
                .disabled(session.positiveSamples.isEmpty)

                Button("Redo Spot", systemImage: "arrow.counterclockwise") {
                    model.retryCalibrationZone()
                }
                .tablemacroSecondaryButton()
                .disabled(session.positiveSamples.isEmpty)

                Spacer()

                Button("Cancel", role: .cancel) {
                    model.cancelCalibration()
                }
            }
        }
        .padding(18)
        .frame(maxWidth: 760)
        .tablemacroCard(tint: session.currentZone.map(TableMacroTheme.color(for:)) ?? TableMacroTheme.accent)
    }

    private func completionControls(_ session: CalibrationSession) -> some View {
        let weakest = model.calibrationValidation.flatMap { weakestResult(in: $0) }
        let needsReview = (model.calibrationValidation?.accuracy ?? 1) < CalibrationGuidance.minimumCleanAgreement

        return VStack(alignment: .leading, spacing: 14) {
            if let validation = model.calibrationValidation {
                consistencyReview(validation)
                Divider()
            }

            HStack {
                if needsReview, let weakest {
                    Button("Redo \(weakest.zone.displayName)") {
                        model.retryCalibrationZone(weakest.zone)
                    }
                    .tablemacroPrimaryButton()
                    .controlSize(.large)

                    Menu("Save Anyway") {
                        Button("Save and Set Macros") {
                            model.finishCalibration(openActions: true)
                        }
                        Button("Save for Later") {
                            model.finishCalibration()
                        }
                    }
                    .tablemacroSecondaryButton()
                } else {
                    Button("Save and Set Macros") {
                        model.finishCalibration(openActions: true)
                    }
                    .tablemacroPrimaryButton()
                    .controlSize(.large)

                    Button("Save for Later") {
                        model.finishCalibration()
                    }
                    .tablemacroSecondaryButton()
                }

                Spacer()
            }

            DisclosureGroup("Teach TableMacro sounds to reject (recommended)", isExpanded: $showRejectionTraining) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Capture Talking first: speak normally for a few seconds. Only speech peaks that reach the classifier are counted, and only acoustic features are saved.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(["Talking", "Typing", "Laptop touch", "Background noise"], id: \.self) { label in
                        HStack {
                            Button {
                                model.collectNegativeExamples(label: session.negativeLabel == label ? nil : label)
                            } label: {
                                Label(
                                    session.negativeLabel == label ? "Stop \(label)" : "Capture \(label)",
                                    systemImage: session.negativeLabel == label ? "stop.circle.fill" : "record.circle"
                                )
                            }
                            .tablemacroSecondaryButton()
                            .disabled(!model.audio.isListening)
                            Text("\(session.negativeCount(for: label)) captured")
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                                .accessibilityLabel("\(session.negativeCount(for: label)) \(label) examples captured")
                            if session.negativeCount(for: label) > 0 {
                                Button("Clear") {
                                    model.clearNegativeExamples(label: label)
                                }
                                .buttonStyle(.borderless)
                                .accessibilityLabel("Clear \(label) examples")
                            }
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(18)
        .frame(maxWidth: 760)
        .tablemacroCard()
    }

    private func consistencyReview(_ validation: CrossValidationResult) -> some View {
        let weakest = weakestResult(in: validation)
        let needsReview = validation.accuracy < CalibrationGuidance.minimumCleanAgreement

        return VStack(alignment: .leading, spacing: 8) {
            Label(
                "Training agreement: \(Int(validation.accuracy * 100))%",
                systemImage: needsReview ? "exclamationmark.triangle" : "checkmark.circle"
            )
            .font(.headline)
            .foregroundStyle(needsReview ? Color.orange : Color.primary)

                    Text("Each tap was classified while left out of training. This checks consistency; it is not the separate test run.")
                .font(.caption)
                .foregroundStyle(.secondary)

            if needsReview, let weakest {
                Text("Weakest spot: \(weakest.zone.displayName) · \(Int(weakest.accuracy * 100))%. Recapture it for a cleaner profile, or save anyway from the secondary menu.")
                    .font(.callout)
            }
        }
    }

    private func weakestResult(in validation: CrossValidationResult) -> ZoneAccuracy? {
        validation.perZoneAccuracy.min { lhs, rhs in
            if lhs.accuracy == rhs.accuracy { return lhs.zone.rawValue < rhs.zone.rawValue }
            return lhs.accuracy < rhs.accuracy
        }
    }

    private func instruction(for session: CalibrationSession) -> String {
        guard session.currentZone != nil else { return "" }
        if session.isSettling {
            return "Move to the highlighted spot. Listening starts automatically."
        }
        if session.isArmed {
            return "Spread natural taps across the highlighted area and pause between taps."
        }
        return "Move to the highlighted spot, then arm it when ready."
    }

    private func settlingMessage(for session: CalibrationSession) -> String {
        guard let zone = session.currentZone else { return "Preparing…" }
        if session.positiveSamples.isEmpty {
            return "Preparing \(zone.displayName)…"
        }
        return "Move to \(zone.displayName) • listening starts automatically"
    }
}
