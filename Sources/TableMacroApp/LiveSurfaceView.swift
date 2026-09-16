import TableMacroCore
import SwiftUI

struct LiveSurfaceView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        if model.selectedProfile == nil {
            setupPrompt
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(36)
                .background(TableMacroTheme.background)
        } else {
            liveDesk
        }
    }

    private var liveDesk: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 20)

            DeskMapView(
                activeZone: model.activeZone,
                targetZone: nil,
                confidence: model.lastDecision?.confidence ?? 0,
                signalStrength: model.lastDecision?.signalStrength ?? model.audio.liveLevel,
                isListening: model.audio.isListening
            )
            .frame(maxWidth: 760, maxHeight: 490)
            .padding(.horizontal, 36)

            resultStrip

            Spacer(minLength: 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 28)
        .background(TableMacroTheme.background)
    }

    private var setupPrompt: some View {
        VStack(spacing: 10) {
            Image(systemName: "scope")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(TableMacroTheme.accent)
            Text("Set up the table around your MacBook")
                .font(.tablemacroTitle(24))
            Text("Taps cannot be assigned until TableMacro learns this table. You will tap ten times across each of four broad spots: far and near on both sides of the MacBook.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 480)
            Text("Microphone access is requested when training begins.")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Button("Set Up Four Spots") {
                model.openSetup()
            }
            .tablemacroPrimaryButton()
            .controlSize(.large)
        }
        .padding(.top, 4)
    }

    private var resultStrip: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 2) {
                Text(lastResultTitle)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(resultTint)
                Text(model.lastDecision?.rejectionReason?.displayName ?? model.selectedProfile?.name ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: 170, alignment: .leading)

            Divider().frame(height: 34)

            compactGauge("Confidence", value: model.lastDecision?.confidence ?? 0, tint: resultTint)
            compactGauge("Signal", value: model.lastDecision?.signalStrength ?? model.audio.liveLevel, tint: resultTint)

            if let latency = model.lastDecision?.processingLatencyMilliseconds, latency > 0 {
                Divider().frame(height: 34)
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(format: "%.1f ms", latency))
                        .font(.callout.monospacedDigit().weight(.semibold))
                    Text("Processing")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button("Retrain", systemImage: "arrow.triangle.2.circlepath") {
                model.prepareRecalibration()
            }
            .tablemacroSecondaryButton()
        }
        .padding(16)
        .frame(maxWidth: 760)
        .tablemacroCard(tint: resultTint)
    }

    private var resultTint: Color {
        model.lastDecision?.zone.map(TableMacroTheme.color(for:)) ?? TableMacroTheme.accent
    }

    private var lastResultTitle: String {
        guard let decision = model.lastDecision else { return "Waiting for a tap" }
        return decision.zone?.displayName ?? "Tap rejected"
    }

    private func compactGauge(_ label: String, value: Double, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                Spacer()
                Text("\(Int(value * 100))%")
                    .monospacedDigit()
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            ProgressView(value: value)
                .tint(tint)
                .frame(width: 112)
        }
    }
}
