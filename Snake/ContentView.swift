import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        GameView(viewModel: viewModel)
    }
}

#Preview {
    ContentView()
}
