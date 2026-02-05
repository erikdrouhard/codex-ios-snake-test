import Foundation

let gridWidth = 20
let gridHeight = 20
let initialSnakeLength = 3

let initialTickMilliseconds = 200
let minimumTickMilliseconds = 80
let tickStepMilliseconds = 5

func tickInterval(forScore score: Int) -> Duration {
    let ms = max(minimumTickMilliseconds, initialTickMilliseconds - (score * tickStepMilliseconds))
    return .milliseconds(ms)
}

enum Direction {
    case up
    case down
    case left
    case right

    var delta: (dx: Int, dy: Int) {
        switch self {
        case .up: return (0, -1)
        case .down: return (0, 1)
        case .left: return (-1, 0)
        case .right: return (1, 0)
        }
    }

    func isOpposite(of other: Direction) -> Bool {
        switch (self, other) {
        case (.up, .down), (.down, .up), (.left, .right), (.right, .left):
            return true
        default:
            return false
        }
    }
}

struct GridPoint: Hashable {
    let x: Int
    let y: Int

    func moved(_ direction: Direction) -> GridPoint {
        let delta = direction.delta
        return GridPoint(x: x + delta.dx, y: y + delta.dy)
    }
}

struct GameState {
    var snake: [GridPoint]
    var direction: Direction
    var pendingDirection: Direction?
    var food: GridPoint
    var score: Int
    var isRunning: Bool
    var isGameOver: Bool
    var tickInterval: Duration
}
