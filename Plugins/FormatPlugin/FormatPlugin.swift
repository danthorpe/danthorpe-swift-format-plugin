// Copied & Modified from https://github.com/apple/swift-format/commit/05aa376c99dfd0defa6e8b0b64e6653463b68bea

import PackagePlugin
import Foundation

@main
struct FormatPlugin: CommandPlugin {
    func performCommand(
        context: PluginContext,
        arguments: [String]
    ) async throws {
        let swiftFormatTool = try context.tool(named: "swift-format")

        var argExtractor = ArgumentExtractor(arguments)
        let targetNames = argExtractor.extractOption(named: "target")
        let targetsToFormat = targetNames.isEmpty ? context.package.targets : try context.package.targets(named: targetNames)

        let configurationFilePath = argExtractor.extractOption(named: "configuration").first

        let sourceCodeTargets = targetsToFormat.compactMap{ $0 as? SourceModuleTarget }

        try format(
            tool: swiftFormatTool,
            targetDirectories: sourceCodeTargets.map(\.directory.string),
            configurationFilePath: configurationFilePath
        )
    }
}

extension FormatPlugin {

    func format(tool: PluginContext.Tool, targetDirectories: [String], configurationFilePath: String?) throws {
        let swiftFormatExec = URL(fileURLWithPath: tool.path.string)

        var arguments: [String] = ["format"]

        arguments.append(contentsOf: targetDirectories)

        arguments.append(contentsOf: ["--recursive", "--parallel", "--in-place"])

        if let configurationFilePath = configurationFilePath {
            arguments.append(contentsOf: ["--configuration", configurationFilePath])
        }

        Diagnostics.remark("Will format with arguments: \(arguments)")

        let process = try Process.run(swiftFormatExec, arguments: arguments)
        process.waitUntilExit()

        if process.terminationReason == .exit && process.terminationStatus == 0 {
            Diagnostics.remark("Finished formatting source code")
        }
        else {
            let problem = "\(process.terminationReason):\(process.terminationStatus)"
            Diagnostics.error("swift-format invocation failed: \(problem)")
        }
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension FormatPlugin: XcodeCommandPlugin {
    func performCommand(context: XcodeProjectPlugin.XcodePluginContext, arguments: [String]) throws {
        let swiftFormatTool = try context.tool(named: "swift-format")

        var argExtractor = ArgumentExtractor(arguments)
        let configurationFilePath = argExtractor.extractOption(named: "configuration").first

        try format(
            tool: swiftFormatTool,
            targetDirectories: [context.xcodeProject.directory.string],
            configurationFilePath: configurationFilePath
        )
    }
}
#endif
