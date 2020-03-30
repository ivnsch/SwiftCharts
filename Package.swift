import PackageDescription

let package = Package(
    name: "SwiftCharts",
    platforms: [
        .iOS(.v7),
    ],
    products: [
        .library(
            name: "SwiftCharts",
            targets: ["SwiftCharts"]),
    ],
    targets: [
        .target(
            name: "SwiftCharts",
            dependencies: []),
        .testTarget(
            name: "SwiftChartsTests",
            dependencies: ["SwiftCharts"]),
    ]
)
