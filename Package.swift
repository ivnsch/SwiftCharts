// swift-tools-version:5.0
import PackageDescription

let package = Package(
     name: "SwiftCharts",
     platforms: [
         .iOS(.v9)
     ],
     products: [
         .library(name: "SwiftCharts", type: .dynamic, targets: ["SwiftCharts"])
     ],
     targets: [
        .target(
               name: "SwiftCharts",
               path: "SwiftCharts"
        )
     ],
     swiftLanguageVersions: [.v5]
 )
