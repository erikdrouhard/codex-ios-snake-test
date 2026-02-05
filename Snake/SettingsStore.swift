import SwiftUI

final class SettingsStore: ObservableObject {
    @AppStorage("highScore") var highScore: Int = 0
    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true
}
