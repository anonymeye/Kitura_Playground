// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "simpleCouchdb",
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/Kitura.git", from: "2.0.0"),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from: Version.init(1, 9, 0)),
        .package(url: "https://github.com/IBM-Swift/Kitura-CouchDB.git", from: "2.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "simpleCouchdb",
            dependencies: ["Kitura", "HeliumLogger", .product(name: "CouchDB", package: "Kitura-CouchDB")]),
        .testTarget(
            name: "simpleCouchdbTests",
            dependencies: ["simpleCouchdb"]),
    ]
)
