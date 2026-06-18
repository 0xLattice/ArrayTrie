// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ArrayTrie",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(name: "ArrayTrie", targets: ["ArrayTrie"]),
    ],
    dependencies: [
        .package(url: "https://github.com/adalinxx/TrieDictionary.git", from: "0.0.9"),
    ],
    targets: [
        .target(
            name: "ArrayTrie",
            dependencies: [
                .product(name: "TrieDictionary", package: "TrieDictionary"),
            ]
        ),
        .testTarget(
            name: "ArrayTrieTests",
            dependencies: ["ArrayTrie"]
        ),
    ]
)
