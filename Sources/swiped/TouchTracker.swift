import Foundation
import OpenMultitouchSupport

struct TrackedTouch {
    let id: Int32
    let positionX: Float
    let positionY: Float
    let velocityX: Float
    let velocityY: Float
    let state: OMSState
}

final class TouchTracker {
    private struct TouchHistory {
        var x: Float
        var y: Float
        var time: TimeInterval
    }

    private var history: [Int32: TouchHistory] = [:]

    func update(frame: [OMSTouchData]) -> [TrackedTouch] {
        let now = ProcessInfo.processInfo.systemUptime
        var result: [TrackedTouch] = []
        var activeIDs = Set<Int32>()

        for touch in frame {
            activeIDs.insert(touch.id)
            let x = touch.position.x
            let y = touch.position.y

            var vx: Float = 0
            var vy: Float = 0

            if let prev = history[touch.id] {
                let dt = Float(now - prev.time)
                if dt > 0 {
                    vx = (x - prev.x) / dt
                    vy = (y - prev.y) / dt
                }
            }

            history[touch.id] = TouchHistory(x: x, y: y, time: now)

            result.append(TrackedTouch(
                id: touch.id,
                positionX: x,
                positionY: y,
                velocityX: vx,
                velocityY: vy,
                state: touch.state
            ))
        }

        // Prune lifted fingers
        for key in history.keys where !activeIDs.contains(key) {
            history.removeValue(forKey: key)
        }

        return result
    }
}
