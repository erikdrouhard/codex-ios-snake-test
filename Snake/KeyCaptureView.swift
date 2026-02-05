import SwiftUI

#if os(macOS)
import AppKit

struct KeyCaptureView: NSViewRepresentable {
    var onDirection: (Direction) -> Void

    func makeNSView(context: Context) -> KeyView {
        let view = KeyView()
        view.onDirection = onDirection
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: KeyView, context: Context) {
        nsView.onDirection = onDirection
        DispatchQueue.main.async {
            nsView.window?.makeFirstResponder(nsView)
        }
    }

    final class KeyView: NSView {
        var onDirection: ((Direction) -> Void)?

        override var acceptsFirstResponder: Bool {
            true
        }

        override func keyDown(with event: NSEvent) {
            if let direction = mapDirection(for: event) {
                onDirection?(direction)
            } else {
                super.keyDown(with: event)
            }
        }

        private func mapDirection(for event: NSEvent) -> Direction? {
            switch event.keyCode {
            case 123: return .left
            case 124: return .right
            case 125: return .down
            case 126: return .up
            default:
                break
            }

            guard let chars = event.charactersIgnoringModifiers?.lowercased(), let first = chars.first else {
                return nil
            }

            switch first {
            case "w": return .up
            case "a": return .left
            case "s": return .down
            case "d": return .right
            default:
                return nil
            }
        }
    }
}
#endif
