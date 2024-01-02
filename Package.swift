// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "swift-spyder",
  platforms: [
    .iOS(.v14),
    .macOS(.v11)
  ],
  products: [
    .library(
      name: "Spyder",
      targets: ["Spyder"]
    )
  ],
  dependencies: [],
  targets: [
    .target(
      name: "Spyder",
      dependencies: [],
      swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
    ),
    .testTarget(
      name: "SpyderTests",
      dependencies: ["Spyder"],
      swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
    )
  ]
)
