import Foundation

enum GameRules {
    static func initialState() -> GameState {
        let startX = gridWidth / 2
        let startY = gridHeight / 2
        let snake = (0..<initialSnakeLength).map { offset in
            GridPoint(x: startX - offset, y: startY)
        }
        let food = randomFood(excluding: snake)
        return GameState(
            snake: snake,
            direction: .right,
            pendingDirection: nil,
            food: food,
            score: 0,
            isRunning: false,
            isGameOver: false,
            tickInterval: tickInterval(forScore: 0)
        )
    }

    static func advance(state: GameState) -> GameState {
        guard state.isRunning, !state.isGameOver else {
            return state
        }

        var next = state
        if let pending = state.pendingDirection, !pending.isOpposite(of: state.direction) {
            next.direction = pending
        }
        next.pendingDirection = nil

        let newHead = state.snake[0].moved(next.direction)

        if newHead.x < 0 || newHead.x >= gridWidth || newHead.y < 0 || newHead.y >= gridHeight {
            next.isGameOver = true
            next.isRunning = false
            return next
        }

        let ate = newHead == state.food
        let bodyToCheck = ate ? state.snake : Array(state.snake.dropLast())
        if bodyToCheck.contains(newHead) {
            next.isGameOver = true
            next.isRunning = false
            return next
        }

        var newSnake = [newHead]
        if ate {
            newSnake.append(contentsOf: state.snake)
        } else {
            newSnake.append(contentsOf: state.snake.dropLast())
        }

        next.snake = newSnake

        if ate {
            next.score += 1
            if newSnake.count == gridWidth * gridHeight {
                // No empty cells remain, so finish the game instead of trying to spawn food.
                next.isGameOver = true
                next.isRunning = false
            } else {
                next.food = randomFood(excluding: newSnake)
                next.tickInterval = tickInterval(forScore: next.score)
            }
        }

        return next
    }

    static func randomFood(excluding snake: [GridPoint]) -> GridPoint {
        var point = GridPoint(x: Int.random(in: 0..<gridWidth), y: Int.random(in: 0..<gridHeight))
        let occupied = Set(snake)
        while occupied.contains(point) {
            point = GridPoint(x: Int.random(in: 0..<gridWidth), y: Int.random(in: 0..<gridHeight))
        }
        return point
    }
}
