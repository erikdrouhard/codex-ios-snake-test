import AudioToolbox
import SwiftUI

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var state: GameState
    let settings: SettingsStore

    private lazy var gameLoop = GameLoop(intervalProvider: { [weak self] in
        self?.state.tickInterval ?? tickInterval(forScore: 0)
    })

    #if os(iOS)
    private let eatHaptic = UIImpactFeedbackGenerator(style: .light)
    private let gameOverHaptic = UINotificationFeedbackGenerator()
    #endif

    init(settings: SettingsStore = SettingsStore()) {
        self.settings = settings
        self.state = GameRules.initialState()
        #if os(iOS)
        eatHaptic.prepare()
        gameOverHaptic.prepare()
        #endif
    }

    func start() {
        if state.isGameOver {
            restart()
            return
        }
        guard !state.isRunning else { return }
        state.isRunning = true
        gameLoop.run { [weak self] in
            self?.advance()
        }
    }

    func pause() {
        guard state.isRunning else { return }
        state.isRunning = false
        gameLoop.stop()
    }

    func resume() {
        guard !state.isRunning, !state.isGameOver else { return }
        state.isRunning = true
        gameLoop.run { [weak self] in
            self?.advance()
        }
    }

    func restart() {
        gameLoop.stop()
        state = GameRules.initialState()
        state.isRunning = true
        gameLoop.run { [weak self] in
            self?.advance()
        }
    }

    func handleDirection(_ direction: Direction) {
        guard !state.isGameOver else { return }
        state.pendingDirection = direction
        if !state.isRunning {
            start()
        }
    }

    private func advance() {
        guard state.isRunning, !state.isGameOver else { return }
        let previousScore = state.score
        let previousGameOver = state.isGameOver

        let next = GameRules.advance(state: state)
        state = next

        if next.score > previousScore {
            playEatFeedback()
        }

        if next.score > settings.highScore {
            settings.highScore = next.score
        }

        if next.isGameOver && !previousGameOver {
            playGameOverFeedback()
            gameLoop.stop()
        }
    }

    private func playEatFeedback() {
        if settings.soundEnabled {
            AudioServicesPlaySystemSound(1104)
        }
        #if os(iOS)
        if settings.hapticsEnabled {
            eatHaptic.impactOccurred()
        }
        #endif
    }

    private func playGameOverFeedback() {
        if settings.soundEnabled {
            AudioServicesPlaySystemSound(1053)
        }
        #if os(iOS)
        if settings.hapticsEnabled {
            gameOverHaptic.notificationOccurred(.error)
        }
        #endif
    }
}
