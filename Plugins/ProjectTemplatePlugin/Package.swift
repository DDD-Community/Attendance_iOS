// swift-tools-version: 5.8
//
//  Package.swift
//  ProjectTemplatePlugin
//
//  Created by DDD on 9/4/26.
//

import PackageDescription

let package = Package(
    name: "MyPlugin",
    products: [
        .executable(name: "tuist-my-cli", targets: ["tuist-my-cli"]),
    ],
    targets: [
        .executableTarget(
            name: "tuist-my-cli"
        ),
    ]
)
