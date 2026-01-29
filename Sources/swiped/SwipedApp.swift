import Foundation
import OpenMultitouchSupport

@main
struct SwipedApp {
    static func main() async {
        let configPath = Self.resolveConfigPath()
        let config = Self.loadConfig(from: configPath)

        let tracker = TouchTracker()
        let recognizer = GestureRecognizer(settings: config.settings)
        let executor = CommandExecutor()

        let manager = OMSManager.shared
        manager.startListening()

        fputs("swiped: listening for gestures... (config: \(configPath))\n", stderr)

        for await frame in manager.touchDataStream {
            let touches = tracker.update(frame: frame)
            if let event = recognizer.process(touches: touches) {
                fputs("swiped: detected \(event.fingerCount)-finger swipe \(event.direction)\n", stderr)
                if let binding = config.binding(for: event) {
                    fputs("swiped: executing \(binding.command)\n", stderr)
                    executor.execute(binding.command)
                } else {
                    fputs("swiped: no binding for gesture\n", stderr)
                }
            }
        }
    }

    private static func resolveConfigPath() -> String {
        let args = CommandLine.arguments
        if let idx = args.firstIndex(of: "--config"), idx + 1 < args.count {
            return args[idx + 1]
        }
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/.config/swiped/config.toml"
    }

    private static func loadConfig(from path: String) -> Config {
        if FileManager.default.fileExists(atPath: path) {
            do {
                return try Config.load(from: path)
            } catch {
                fputs("swiped: error loading config: \(error)\n", stderr)
                exit(1)
            }
        } else {
            do {
                try Config.generateDefault(at: path)
                fputs("swiped: generated default config at \(path)\n", stderr)
                return try Config.load(from: path)
            } catch {
                fputs("swiped: error generating default config: \(error)\n", stderr)
                exit(1)
            }
        }
    }
}
