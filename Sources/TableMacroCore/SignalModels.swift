import Foundation

/// Objective measurements of one captured analysis window, used both to guide
/// calibration retries and to gate classification before any distance math runs.
public struct SignalQuality: Codable, Equatable, Sendable {
    public static let minimumReliablePeakAmplitude = 0.003
    public static let maximumReliableClippingFraction = 0.20
    public static let minimumClassificationSignalToNoiseDB = 6.0

    public var signalToNoiseDB: Double
    public var peakAmplitude: Double
    public var rmsAmplitude: Double
    public var clippingFraction: Double
    public var noiseFloorRMS: Double
    public var durationMilliseconds: Double

    public init(
        signalToNoiseDB: Double,
        peakAmplitude: Double,
        rmsAmplitude: Double,
        clippingFraction: Double,
        noiseFloorRMS: Double,
        durationMilliseconds: Double
    ) {
        self.signalToNoiseDB = signalToNoiseDB
        self.peakAmplitude = peakAmplitude
        self.rmsAmplitude = rmsAmplitude
        self.clippingFraction = clippingFraction
        self.noiseFloorRMS = noiseFloorRMS
        self.durationMilliseconds = durationMilliseconds
    }

    /// A single 0...1 quality figure blending noise headroom, loudness, and
    /// clipping. Weighted toward signal-to-noise because a quiet but clean tap
    /// is far more recoverable than a loud but masked one.
    public var score: Double {
        let snr = min(max((signalToNoiseDB - 4) / 30, 0), 1)
        let strength = min(max((peakAmplitude - Self.minimumReliablePeakAmplitude) / 0.15, 0), 1)
        let clean = 1 - min(clippingFraction * 4, 1)
        return 0.55 * snr + 0.25 * strength + 0.20 * clean
    }

    public var summary: String {
        if clippingFraction > Self.maximumReliableClippingFraction { return "Clipped" }
        if peakAmplitude < Self.minimumReliablePeakAmplitude { return "Weak" }
        if signalToNoiseDB < Self.minimumClassificationSignalToNoiseDB { return "Noisy" }
        if score > 0.72 { return "Excellent" }
        if score > 0.48 { return "Good" }
        return "Fair"
    }
}

/// A named, ordered feature vector extracted from one detected window, tagged
/// with the sensing strategy that produced it so mismatched profiles can be
/// rejected instead of silently misinterpreted.
public struct TapFeatureVector: Codable, Equatable, Sendable {
    public static let schemaVersion = 1

    public var version: Int
    public var strategy: SensingStrategy
    public var names: [String]
    public var values: [Double]
    public var quality: SignalQuality
    public var capturedAt: Date

    public init(
        strategy: SensingStrategy,
        names: [String],
        values: [Double],
        quality: SignalQuality,
        capturedAt: Date = Date()
    ) {
        self.version = Self.schemaVersion
        self.strategy = strategy
        self.names = names
        self.values = values
        self.quality = quality
        self.capturedAt = capturedAt
    }
}

/// One calibration or rejection-training example: either a zone-labeled tap
/// or a negative example (talking, typing, and similar sounds to reject).
public struct LabeledTap: Codable, Equatable, Sendable, Identifiable {
    public var id: UUID
    public var zone: DeskZone?
    public var negativeLabel: String?
    public var feature: TapFeatureVector

    public init(
        id: UUID = UUID(),
        zone: DeskZone?,
        negativeLabel: String? = nil,
        feature: TapFeatureVector
    ) {
        self.id = id
        self.zone = zone
        self.negativeLabel = negativeLabel
        self.feature = feature
    }
}

/// A raw multichannel analysis window produced by the streaming detector,
/// before any feature extraction. Retained only transiently in memory.
public struct DetectedTap: Sendable {
    public var channels: [[Float]]
    public var onsetOffset: Int
    public var streamSampleIndex: Int64
    public var noiseFloorRMS: Double

    public init(
        channels: [[Float]],
        onsetOffset: Int,
        streamSampleIndex: Int64,
        noiseFloorRMS: Double
    ) {
        self.channels = channels
        self.onsetOffset = onsetOffset
        self.streamSampleIndex = streamSampleIndex
        self.noiseFloorRMS = noiseFloorRMS
    }
}

/// One bar of a coarse frequency-response chart, used by Diagnostics.
public struct SpectrumBand: Codable, Equatable, Sendable, Identifiable {
    public var id: Int { Int(centerFrequency.rounded()) }
    public var centerFrequency: Double
    public var levelDB: Double

    public init(centerFrequency: Double, levelDB: Double) {
        self.centerFrequency = centerFrequency
        self.levelDB = levelDB
    }
}
