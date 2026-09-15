import TableMacroCore
import SwiftUI

struct DeskMapView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var activeZone: DeskZone?
    var targetZone: DeskZone?
    var confidence: Double
    var signalStrength: Double
    var isListening: Bool
    var counts: [Int]? = nil

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let horizontalGap = width * 0.035
            let sideWidth = width * 0.29
            let laptopWidth = width - sideWidth * 2 - horizontalGap * 2

            HStack(spacing: horizontalGap) {
                sideRail(isLeft: true)
                    .frame(width: sideWidth, height: height)

                MacBookSilhouette(isListening: isListening, tint: activeTint)
                    .frame(width: laptopWidth, height: height * 0.70)

                sideRail(isLeft: false)
                    .frame(width: sideWidth, height: height)
            }
            .frame(width: width, height: height)
        }
        .aspectRatio(1.58, contentMode: .fit)
        .animation(reduceMotion ? nil : .snappy(duration: 0.22), value: activeZone)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: targetZone)
    }

    private var activeTint: Color {
        (activeZone ?? targetZone).map(TableMacroTheme.color(for:)) ?? TableMacroTheme.accent
    }

    private func sideRail(isLeft: Bool) -> some View {
        let zones = DeskZone.allCases.filter { $0.isLeft == isLeft }

        return VStack(spacing: 7) {
            ForEach(zones) { zone in
                zoneRow(zone)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func zoneRow(_ zone: DeskZone) -> some View {
        let isActive = zone == activeZone
        let isTarget = zone == targetZone
        let tint = TableMacroTheme.color(for: zone)

        return HStack(spacing: 10) {
            if zone.isLeft { Spacer(minLength: 0) }

            if !zone.isLeft {
                zoneIndicator(tint: tint, active: isActive, target: isTarget)
            }

            VStack(alignment: zone.isLeft ? .trailing : .leading, spacing: 3) {
                Text(zone.positionName)
                    .font(.callout.weight(.bold))
                Text(zone.isLeft ? "Left" : "Right")
                    .font(.caption.weight(.medium))
                    .foregroundStyle((isActive || isTarget) ? tint : .secondary)
            }

            if let counts, zone.rawValue < counts.count {
                Text("\(counts[zone.rawValue])")
                    .font(.caption.monospacedDigit().weight(.bold))
                    .foregroundStyle(tint)
            }

            if zone.isLeft {
                zoneIndicator(tint: tint, active: isActive, target: isTarget)
            }

            if !zone.isLeft { Spacer(minLength: 0) }
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(zoneFill(tint: tint, active: isActive, target: isTarget))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    zoneStroke(tint: tint, active: isActive, target: isTarget),
                    lineWidth: isActive ? 2.5 : 1.5
                )
        )
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(zone.displayName)
        .accessibilityValue(accessibilityValue(for: zone, active: isActive, target: isTarget))
        .help(zone.instruction)
    }

    private func zoneIndicator(tint: Color, active: Bool, target: Bool) -> some View {
        Circle()
            .fill(active || target ? tint : Color.primary.opacity(0.12))
            .frame(width: active ? 14 : 10, height: active ? 14 : 10)
            .shadow(color: active ? tint.opacity(0.6) : .clear, radius: active ? 6 : 0)
    }

    private func zoneFill(tint: Color, active: Bool, target: Bool) -> Color {
        if active { return tint.opacity(0.24 + min(signalStrength, 1) * 0.12) }
        if target { return tint.opacity(0.13) }
        return tint.opacity(0.05)
    }

    private func zoneStroke(tint: Color, active: Bool, target: Bool) -> Color {
        if active { return tint }
        if target { return tint.opacity(0.6) }
        return tint.opacity(0.20)
    }

    private func accessibilityValue(for zone: DeskZone, active: Bool, target: Bool) -> String {
        var parts: [String] = []
        if target { parts.append("Current target") }
        if active { parts.append("Last detected, \(Int(confidence * 100)) percent confidence") }
        if let counts, zone.rawValue < counts.count { parts.append("\(counts[zone.rawValue]) captured") }
        return parts.isEmpty ? "Inactive" : parts.joined(separator: ", ")
    }
}

private struct MacBookSilhouette: View {
    var isListening: Bool
    var tint: Color

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.16), tint.opacity(0.04)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(tint.opacity(0.4), lineWidth: 1.5)
                    )
                    .frame(width: width * 0.88, height: height * 0.86)
                    .offset(y: -height * 0.055)

                VStack(spacing: 8) {
                    Image(systemName: isListening ? "waveform" : "pause.fill")
                        .font(.title.weight(.bold))
                        .foregroundStyle(isListening ? tint : Color.secondary)
                        .symbolEffect(.pulse, isActive: isListening)
                    Text("MacBook")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                .offset(y: -height * 0.29)

                Capsule()
                    .fill(tint.opacity(0.55))
                    .frame(width: width * 0.4, height: max(height * 0.05, 5))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isListening ? "MacBook, microphone active" : "MacBook, microphone paused")
    }
}
