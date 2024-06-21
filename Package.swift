// swift-tools-version: 5.7
import PackageDescription

var package = Package(name: "danthorpe-swift-format-plugin")

// MARK: - Names
let Binary = "Binary"
let FormatPlugin = "Format Source Code"
let LintPlugin = "Lint Source Code"

// MARK: 💫 Package Customization

package.defaultLocalization = "en"
package.platforms = [
    .macOS(.v12),
    .iOS(.v14),
    .tvOS(.v14),
    .watchOS(.v7)
]

/// ✨ These are all special case targets, such as plugins
/// ------------------------------------------------------------

// MARK: - 🧮 Binary Targets & Plugins

extension Target {
    static let binary: Target = .binaryTarget(
        name: Binary,
        url: "https://github.com/danthorpe/danthorpe-swift-format-plugin/releases/download/0.2.0/swift-format.artifactbundle.zip",
        checksum: "247a14f2e0fbca0c52a121fd76aab0202d93258571469361fe6734bd2996929b"
    )

    static let formatPlugin: Target = .plugin(
        name: FormatPlugin,
        capability: .command(
            intent: .sourceCodeFormatting(),
            permissions: [
                .writeToPackageDirectory(reason: "This command formats the Swift source files")
            ]
        ),
        dependencies: [
            .target(name: Binary)
        ],
        path: "Plugins/FormatPlugin"
    )

    static let lintPlugin: Target = .plugin(
        name: LintPlugin,
        capability: .command(
            intent: .custom(
                verb: "lint-source-code",
                description: "Lint source code for a specified target."
            )
        ),
        dependencies: [
            .target(name: Binary)
        ],
        path: "Plugins/LintPlugin"
    )
}

var plugins: [Target] = [
    .binary,
    .formatPlugin,
    .lintPlugin
]

package.targets.append(contentsOf: plugins)

// MARK: Products

package.products = [
    .plugin(name: FormatPlugin, targets: [FormatPlugin]),
    .plugin(name: LintPlugin, targets: [LintPlugin]),
]
