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
        url: "https://github.com/danthorpe/danthorpe-swift-format-plugin/releases/download/untagged-9f39ee5ff83a0ffa5dd3/swift-format.artifactbundle.zip",
        checksum: "b3cdada3dedd0081ceb0fb106f42bdf847603b4126da180ca16285d20caa3269"
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
            Binary
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
            Binary
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
