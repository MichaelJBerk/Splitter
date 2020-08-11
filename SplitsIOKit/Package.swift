// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SplitsIOKit",
	platforms: [.macOS(SupportedPlatform.MacOSVersion.v10_14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SplitsIOKit",
            targets: ["SplitsIOKit"]),
    ],
    dependencies: [
		.package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .upToNextMajor(from: "5.0.0")),
		.package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.2.0")),
		.package(name: "Fuzzy", url: "https://github.com/khoi/fuzzy-swift", .upToNextMajor(from: "0.1.0")),
		.package(name: "Files", url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
		.package(name: "OAuth2", url: "https://github.com/p2/OAuth2.git", .upToNextMajor(from: "5.2.0"))
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SplitsIOKit",
			dependencies: ["SwiftyJSON", "Fuzzy", "Alamofire", "Files", "OAuth2"]),
        .testTarget(
            name: "SplitsIOKitTests",
			dependencies: ["SplitsIOKit", "Files"]),
    ]
)
