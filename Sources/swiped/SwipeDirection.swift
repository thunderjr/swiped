enum SwipeDirection: String, Codable {
    case left, right, up, down

    static func classify(velocityX vx: Float, velocityY vy: Float) -> SwipeDirection? {
        let absX = abs(vx)
        let absY = abs(vy)
        if absX > absY {
            return vx > 0 ? .right : .left
        } else if absY > absX {
            return vy > 0 ? .up : .down
        }
        return nil
    }
}
