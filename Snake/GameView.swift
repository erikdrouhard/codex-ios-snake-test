import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var settings: SettingsStore

    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
        self.settings = viewModel.settings
    }

    var body: some View {
        VStack(spacing: 12) {
            headerView
            boardView
        }
        .padding()
    }

    private var headerView: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Score: \(viewModel.state.score)")
                    .font(.headline)
                Text("High: \(settings.highScore)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(controlButtonTitle) {
                if viewModel.state.isGameOver {
                    viewModel.restart()
                } else if viewModel.state.isRunning {
                    viewModel.pause()
                } else if viewModel.state.score == 0 {
                    viewModel.start()
                } else {
                    viewModel.resume()
                }
            }
            .buttonStyle(.bordered)

            Toggle("Sound", isOn: $settings.soundEnabled)
                .toggleStyle(.switch)
                .labelsHidden()
                .accessibilityLabel("Sound")

            Toggle("Haptics", isOn: $settings.hapticsEnabled)
                .toggleStyle(.switch)
                .labelsHidden()
                .accessibilityLabel("Haptics")
        }
    }

    private var boardView: some View {
        ZStack {
            GeometryReader { proxy in
                Canvas { context, size in
                    let cellSize = min(size.width / CGFloat(gridWidth), size.height / CGFloat(gridHeight))
                    let boardSize = CGSize(width: CGFloat(gridWidth) * cellSize, height: CGFloat(gridHeight) * cellSize)
                    let origin = CGPoint(x: (size.width - boardSize.width) / 2, y: (size.height - boardSize.height) / 2)

                    func rect(for point: GridPoint) -> CGRect {
                        CGRect(
                            x: origin.x + CGFloat(point.x) * cellSize,
                            y: origin.y + CGFloat(point.y) * cellSize,
                            width: cellSize,
                            height: cellSize
                        )
                    }

                    var gridPath = Path()
                    for row in 0...gridHeight {
                        let y = origin.y + CGFloat(row) * cellSize
                        gridPath.move(to: CGPoint(x: origin.x, y: y))
                        gridPath.addLine(to: CGPoint(x: origin.x + boardSize.width, y: y))
                    }
                    for col in 0...gridWidth {
                        let x = origin.x + CGFloat(col) * cellSize
                        gridPath.move(to: CGPoint(x: x, y: origin.y))
                        gridPath.addLine(to: CGPoint(x: x, y: origin.y + boardSize.height))
                    }
                    context.stroke(gridPath, with: .color(.gray.opacity(0.2)), lineWidth: 1)

                    let inset = cellSize * 0.08
                    for (index, segment) in viewModel.state.snake.enumerated() {
                        let rect = rect(for: segment).insetBy(dx: inset, dy: inset)
                        let path = Path(roundedRect: rect, cornerRadius: cellSize * 0.2)
                        let color: Color = index == 0 ? .green : .green.opacity(0.8)
                        context.fill(path, with: .color(color))
                    }

                    let foodRect = rect(for: viewModel.state.food).insetBy(dx: inset, dy: inset)
                    let foodPath = Path(ellipseIn: foodRect)
                    context.fill(foodPath, with: .color(.red))
                }
            }
            .aspectRatio(CGFloat(gridWidth) / CGFloat(gridHeight), contentMode: .fit)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onEnded { value in
                        let dx = value.translation.width
                        let dy = value.translation.height
                        if abs(dx) > abs(dy) {
                            viewModel.handleDirection(dx > 0 ? .right : .left)
                        } else {
                            viewModel.handleDirection(dy > 0 ? .down : .up)
                        }
                    }
            )
            .onTapGesture {
                if !viewModel.state.isRunning {
                    viewModel.start()
                }
            }

            overlayView

            #if os(macOS)
            KeyCaptureView { direction in
                viewModel.handleDirection(direction)
                if !viewModel.state.isRunning {
                    viewModel.start()
                }
            }
            .frame(width: 0, height: 0)
            #endif
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        if viewModel.state.isGameOver {
            VStack(spacing: 12) {
                Text("Game Over")
                    .font(.title.bold())
                Text("Score: \(viewModel.state.score)")
                    .font(.headline)
                Button("Restart") {
                    viewModel.restart()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        } else if !viewModel.state.isRunning && viewModel.state.score == 0 {
            VStack(spacing: 8) {
                Text("Classic Snake")
                    .font(.title2.bold())
                Text("Tap or press an arrow key to start")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private var controlButtonTitle: String {
        if viewModel.state.isGameOver {
            return "Restart"
        }
        if viewModel.state.isRunning {
            return "Pause"
        }
        return viewModel.state.score == 0 ? "Start" : "Resume"
    }
}

#Preview {
    GameView(viewModel: GameViewModel())
        .frame(width: 600, height: 600)
}
