// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "WebServer",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        
        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        
        // 👤 Authentication and Authorization layer for Fluent.
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
        
//        .package(url: "https://github.com/kylef/Spectre.git", from: "0.9.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "1.3.2"),
        
        .package(url: "https://github.com/Quick/Nimble.git", from: "7.3.1"),
        
    ],
    targets: [
        .target(name: "App", dependencies: ["Authentication", "FluentSQLite", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "Quick", "Nimble"])
    ]
)

