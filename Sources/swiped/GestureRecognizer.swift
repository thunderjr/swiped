import Foundation
import OpenMultitouchSupport

struct SwipeEvent {
    let direction: SwipeDirection
    let fingerCount: Int
}

final class GestureRecognizer {
    private enum State {
        case idle
        case possibleSwipe(fingerIDs: Set<Int32>, fingerCount: Int)
        case cooldown(until: TimeInterval)
    }

    private let velocityThreshold: Float
    private let cooldownSeconds: TimeInterval
    private var state: State = .idle

    init(settings: Settings) {
        self.velocityThreshold = settings.velocityThreshold
        self.cooldownSeconds = TimeInterval(settings.cooldownMs) / 1000.0
    }

    func process(touches: [TrackedTouch]) -> SwipeEvent? {
        let now = ProcessInfo.processInfo.systemUptime

        switch state {
        case .idle:
            let active = touches.filter { $0.state == .touching }
            if active.count >= 3 {
                let ids = Set(active.map(\.id))
                state = .possibleSwipe(fingerIDs: ids, fingerCount: active.count)
            }
            return nil

        case .possibleSwipe(var fingerIDs, _):
            let active = touches.filter { $0.state == .touching }
            let currentIDs = Set(active.map(\.id))

            // Reset if any original fingers were lifted
            if !fingerIDs.isSubset(of: currentIDs) {
                state = .idle
                return nil
            }

            // Include any newly added fingers
            fingerIDs = currentIDs
            state = .possibleSwipe(fingerIDs: fingerIDs, fingerCount: active.count)

            // Check velocity of all active fingers
            guard !active.isEmpty else {
                state = .idle
                return nil
            }

            let avgVX = active.map(\.velocityX).reduce(0, +) / Float(active.count)
            let avgVY = active.map(\.velocityY).reduce(0, +) / Float(active.count)

            let speed = max(abs(avgVX), abs(avgVY))
            if speed > velocityThreshold {
                if let direction = SwipeDirection.classify(velocityX: avgVX, velocityY: avgVY) {
                    state = .cooldown(until: now + cooldownSeconds)
                    return SwipeEvent(direction: direction, fingerCount: active.count)
                }
            }
            return nil

        case .cooldown(let until):
            if now >= until {
                state = .idle
            }
            return nil
        }
    }
}
