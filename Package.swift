// swift-tools-version:5.4

import PackageDescription

let package = Package(
  name: "RGMagpie",
  platforms: [
    .iOS(.v14)
  ],
  products: [
    .library(name: "RGMagpie", targets: ["RGMagpie"])
  ],
  targets: [
    .target(name: "RGMagpie", path: "RGMagpie/Classes")
  ],
  swiftLanguageVersions: [
    .v5
  ]
)
