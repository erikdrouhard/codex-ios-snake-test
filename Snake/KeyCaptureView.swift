import SwiftUI

#if os(iOS)
import UIKit

struct KeyCaptureView: UIViewRepresentable {
    var onDirection: (Direction) -> Void

    func makeUIView(context: Context) -> KeyView {
        let view = KeyView()
        view.onDirection = onDirection
        DispatchQueue.main.async {
            view.becomeFirstResponder()
        }
        return view
    }

    func updateUIView(_ uiView: KeyView, context: Context) {
        uiView.onDirection = onDirection
        DispatchQueue.main.async {
            if !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
            }
        }
    }

    final class KeyView: UIView {
        var onDirection: ((Direction) -> Void)?

        override var canBecomeFirstResponder: Bool {
            true
        }

        override var keyCommands: [UIKeyCommand]? {
            [
                UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(handleKey(_:))),
                UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(handleKey(_:))),
                UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(handleKey(_:))),
                UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [], action: #selector(handleKey(_:))),
                UIKeyCommand(input: "w", modifierFlags: [], action: #selector(handleKey(_:))),
                UIKeyCommand(input: "a", modifierFlags: [], action: #selector(handleKey(_:))),
                UIKeyCommand(input: "s", modifierFlags: [], action: #selector(handleKey(_:))),
                UIKeyCommand(input: "d", modifierFlags: [], action: #selector(handleKey(_:))),
            ]
        }

        @objc private func handleKey(_ command: UIKeyCommand) {
            guard let direction = mapDirection(for: command) else { return }
            onDirection?(direction)
        }

        private func mapDirection(for command: UIKeyCommand) -> Direction? {
            let input = command.input ?? ""
            switch input {
            case UIKeyCommand.inputUpArrow: return .up
            case UIKeyCommand.inputDownArrow: return .down
            case UIKeyCommand.inputLeftArrow: return .left
            case UIKeyCommand.inputRightArrow: return .right
            default: break
            }

            switch input.lowercased() {
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
