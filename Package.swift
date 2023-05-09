// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GenerativeArtificialNeuralNetwork",
    products: [
        .executable(name: "GenerativeArtificialNeuralNetwork", targets: ["Sources"]),
    ],
    targets: [
        .executableTarget (
            name: "Sources",
            dependencies: [],
            path: "./Sources"
        )
    ]
)
