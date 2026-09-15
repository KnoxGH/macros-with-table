import Foundation

/// Converts between an audio stream's sample-count timeline and the host
/// wall clock, so response latency can be measured from the true onset of a
/// tap rather than from whenever the enclosing buffer happened to be delivered.
public enum AudioTimeline {
    public static let invalidElapsedMilliseconds = -1.0

    /// Maps an event's absolute stream sample index onto the host clock of a
    /// captured buffer. The event can begin in the current buffer or in an
    /// earlier buffer whose window only just finished filling.
    public static func eventHostTimeSeconds(
        bufferStartHostTimeSeconds: Double,
        bufferStartSampleIndex: Int64,
        eventSampleIndex: Int64,
        sampleRate: Double
    ) -> Double {
        guard bufferStartHostTimeSeconds.isFinite, sampleRate.isFinite, sampleRate > 0 else {
            return bufferStartHostTimeSeconds.isFinite ? bufferStartHostTimeSeconds : 0
        }
        let sampleOffset = eventSampleIndex - bufferStartSampleIndex
        return bufferStartHostTimeSeconds + Double(sampleOffset) / sampleRate
    }

    /// Milliseconds between an event's host time and now, or the sentinel
    /// value when the clocks disagree (a negative gap or a non-finite input),
    /// so bad timing never masquerades as a fast response.
    public static func elapsedMilliseconds(
        since eventHostTimeSeconds: Double,
        now nowHostTimeSeconds: Double
    ) -> Double {
        guard eventHostTimeSeconds.isFinite,
              nowHostTimeSeconds.isFinite,
              nowHostTimeSeconds >= eventHostTimeSeconds else {
            return invalidElapsedMilliseconds
        }
        return (nowHostTimeSeconds - eventHostTimeSeconds) * 1_000
    }
}
