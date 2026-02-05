import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        GameView(viewModel: viewModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .modifier(MacWindowSizing())
    }
}

private struct MacWindowSizing: ViewModifier {
    func body(content: Content) -> some View {
        #if os(macOS)
        content.frame(minWidth: 520, minHeight: 640)
        #else
        content
        #endif
    }
}

#Preview {
    ContentView()
}
