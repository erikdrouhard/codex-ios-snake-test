import Foundation

final class GameLoop {
    private let intervalProvider: () -> Duration
    private var task: Task<Void, Never>?

    init(intervalProvider: @escaping () -> Duration) {
        self.intervalProvider = intervalProvider
    }

    func run(tick: @MainActor @escaping () -> Void) {
        stop()
        task = Task {
            let clock = ContinuousClock()
            while !Task.isCancelled {
                let interval = intervalProvider()
                try? await clock.sleep(for: interval)
                if Task.isCancelled {
                    break
                }
                await tick()
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }
}
