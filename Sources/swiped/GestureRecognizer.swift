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

        case .possibleSwipe(let fingerIDs, let fingerCount):
            let active = touches.filter { $0.state == .touching }
            let currentIDs = Set(active.map(\.id))

            // Reset if finger set changed significantly
            if !fingerIDs.isSubset(of: currentIDs) {
                state = .idle
                return nil
            }

            // Check average velocity of tracked fingers
            let tracked = active.filter { fingerIDs.contains($0.id) }
            guard !tracked.isEmpty else {
                state = .idle
                return nil
            }

            let avgVX = tracked.map(\.velocityX).reduce(0, +) / Float(tracked.count)
            let avgVY = tracked.map(\.velocityY).reduce(0, +) / Float(tracked.count)

            let speed = max(abs(avgVX), abs(avgVY))
            if speed > velocityThreshold {
                if let direction = SwipeDirection.classify(velocityX: avgVX, velocityY: avgVY) {
                    state = .cooldown(until: now + cooldownSeconds)
                    return SwipeEvent(direction: direction, fingerCount: fingerCount)
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
