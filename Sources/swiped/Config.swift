import Foundation
import TOMLKit

struct GestureBinding: Codable {
    let direction: SwipeDirection
    let fingers: Int
    let command: [String]
}

struct Settings: Codable {
    var velocityThreshold: Float = 0.3
    var cooldownMs: Int = 250

    enum CodingKeys: String, CodingKey {
        case velocityThreshold = "velocity_threshold"
        case cooldownMs = "cooldown_ms"
    }
}

struct Config: Codable {
    var settings: Settings = Settings()
    var gestures: [GestureBinding] = []

    static func load(from path: String) throws -> Config {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let toml = String(data: data, encoding: .utf8)!
        return try TOMLDecoder().decode(Config.self, from: toml)
    }

    static func generateDefault(at path: String) throws {
        let url = URL(fileURLWithPath: path)
        let dir = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let defaultConfig = Config(
            settings: Settings(),
            gestures: [
                GestureBinding(
                    direction: .left, fingers: 3,
                    command: ["/opt/homebrew/bin/aerospace", "workspace", "next"]
                ),
                GestureBinding(
                    direction: .right, fingers: 3,
                    command: ["/opt/homebrew/bin/aerospace", "workspace", "prev"]
                ),
            ]
        )

        let toml = try TOMLEncoder().encode(defaultConfig)
        try toml.write(to: url, atomically: true, encoding: .utf8)
    }

    func binding(for event: SwipeEvent) -> GestureBinding? {
        gestures.first { $0.direction == event.direction && $0.fingers == event.fingerCount }
    }
}
