import Foundation

final class CommandExecutor {
    func execute(_ command: [String]) {
        guard let executable = command.first else { return }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = Array(command.dropFirst())

        do {
            try process.run()
        } catch {
            FileHandle.standardError.write(
                Data("swiped: failed to execute \(command): \(error)\n".utf8)
            )
        }
    }
}
