// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "Casanchess",
  platforms: [
    .iOS(.v18),
    .macOS(.v14)
  ],
  products: [
    .library(name: "Casanchess", targets: ["Casanchess"])
  ],
  targets: [
    .target(
      name: "Casanchess",
      dependencies: ["CasanchessBridge"],
      resources: [
        .copy("network-20220625.nnue"),
        .copy("syzygy")
      ]
    ),
    .target(
      name: "CasanchessBridge",
      dependencies: ["casanchess"],
      publicHeadersPath: "include",
      cxxSettings: [
        .headerSearchPath("../../Vendor/casanchess-headers"),
        .headerSearchPath("../../Vendor/fathom-src")
      ]
    ),
    .binaryTarget(
      name: "casanchess",
      path: "../../../artifacts/apple/casanchess.xcframework"
    )
  ],
  cxxLanguageStandard: .cxx20
)
