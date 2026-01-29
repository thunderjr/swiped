import Foundation

final class CommandExecutor {
    func execute(_ command: [String]) {
        guard let executable = command.first else { return }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = Array(command.dropFirst())
        process.standardInput = FileHandle.nullDevice
        process.standardOutput = FileHandle.nullDevice

        let stderrPipe = Pipe()
        process.standardError = stderrPipe

        do {
            try process.run()
            process.waitUntilExit()

            let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
            if !stderrData.isEmpty, let stderrStr = String(data: stderrData, encoding: .utf8) {
                fputs("swiped: command stderr: \(stderrStr)", stderr)
            }
            if process.terminationStatus != 0 {
                fputs("swiped: command exited with status \(process.terminationStatus)\n", stderr)
            }
        } catch {
            fputs("swiped: failed to execute \(command): \(error)\n", stderr)
        }
    }
}
