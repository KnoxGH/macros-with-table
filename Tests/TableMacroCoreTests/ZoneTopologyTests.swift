import XCTest
@testable import TableMacroCore

final class ZoneTopologyTests: XCTestCase {
    func testDeskHasExactlyTwoZonesOnEachSideOfMacBook() {
        XCTAssertEqual(DeskZone.allCases.count, 4)
        XCTAssertEqual(
            DeskZone.allCases.filter(\.isLeft),
            [.leftTop, .leftBottom]
        )
        XCTAssertEqual(
            DeskZone.allCases.filter { !$0.isLeft },
            [.rightTop, .rightBottom]
        )
        XCTAssertEqual(DeskZone.allCases.map(\.verticalIndex), [0, 1, 0, 1])
        XCTAssertEqual(DeskZone.allCases.map(\.shortName), ["FL", "NL", "FR", "NR"])
        XCTAssertEqual(DeskZone.allCases.map(\.positionName), ["Far", "Near", "Far", "Near"])
    }

    func testDefaultProfileConfigurationHasOneActionPerZone() throws {
        let classifier = try TrainedTapClassifier.train(positiveExamples: trainingSamples())
        let profile = TableMacroProfile(
            name: "Four zone desk",
            surfaceDescription: "Wood",
            laptopPositionNote: "Centered",
            classifier: classifier,
            calibration: CalibrationSummary(
                sampleCount: 8,
                samplesPerZone: Array(repeating: 2, count: 4),
                leaveOneOutAccuracy: nil
            )
        )

        XCTAssertEqual(profile.zones.map(\.zone), DeskZone.allCases)
        XCTAssertEqual(profile.zones.count, 4)
    }

    private func trainingSamples() -> [LabeledTap] {
        DeskZone.allCases.flatMap { zone in
            (0..<2).map { index in
                LabeledTap(
                    zone: zone,
                    feature: TapFeatureVector(
                        strategy: .passive,
                        names: ["vertical", "side"],
                        values: [
                            Double(zone.verticalIndex) + Double(index) * 0.01,
                            Double(zone.column) + Double(index) * 0.01
                        ],
                        quality: SignalQuality(
                            signalToNoiseDB: 20,
                            peakAmplitude: 0.1,
                            rmsAmplitude: 0.02,
                            clippingFraction: 0,
                            noiseFloorRMS: 0.001,
                            durationMilliseconds: 90
                        )
                    )
                )
            }
        }
    }
}
