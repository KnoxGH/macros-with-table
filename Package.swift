// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TableMacro",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "TableMacroCore", targets: ["TableMacroCore"]),
        .executable(name: "TableMacroSoak", targets: ["TableMacroSoak"]),
        .executable(name: "TableMacroReplay", targets: ["TableMacroReplay"])
    ],
    targets: [
        .target(name: "TableMacroCore", path: "Sources/TableMacroCore"),
        .executableTarget(
            name: "TableMacroSoak",
            dependencies: ["TableMacroCore"],
            path: "Sources/TableMacroSoak"
        ),
        .target(
            name: "TableMacroReplaySupport",
            dependencies: ["TableMacroCore"],
            path: "Sources/TableMacroReplaySupport"
        ),
        .executableTarget(
            name: "TableMacroReplay",
            dependencies: ["TableMacroCore", "TableMacroReplaySupport"],
            path: "Sources/TableMacroReplay"
        ),
        .testTarget(
            name: "TableMacroCoreTests",
            dependencies: ["TableMacroCore"],
            path: "Tests/TableMacroCoreTests"
        ),
        .testTarget(
            name: "TableMacroReplayTests",
            dependencies: ["TableMacroReplaySupport", "TableMacroCore"],
            path: "Tests/TableMacroReplayTests"
        )
    ]
)
