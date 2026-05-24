import Carbon
import Foundation
import SwiftUI

@MainActor
final class HotkeyManager {
    enum Action: UInt32, CaseIterable {
        case toggleVisibility = 1
        case toggleClickThrough = 2
        case increaseFontSize = 3
        case decreaseFontSize = 4
        case increaseOpacity = 5
        case decreaseOpacity = 6
        case toggleAutoScroll = 7
        case snapToCamera = 8
    }

    struct Shortcut {
        let keyCode: UInt32
        let modifiers: UInt32
    }

    struct MenuShortcut {
        let key: KeyEquivalent
        let modifiers: SwiftUI.EventModifiers
    }

    private static let signature: OSType = 0x47484E54 // GHNT
    private static weak var shared: HotkeyManager?

    private var hotKeyRefs: [EventHotKeyRef?] = []
    private let handler: (Action) -> Void

    init(handler: @escaping (Action) -> Void) {
        self.handler = handler
        Self.shared = self

        installEventHandlerIfNeeded()
        registerHotkeys()
    }

    deinit {
        for hotKeyRef in hotKeyRefs {
            if let hotKeyRef {
                UnregisterEventHotKey(hotKeyRef)
            }
        }
    }

    static func description(for action: Action) -> String {
        switch action {
        case .toggleVisibility:
            "Control-Option-Command-O"
        case .toggleClickThrough:
            "Control-Option-Command-L"
        case .increaseFontSize:
            "Control-Option-Command-="
        case .decreaseFontSize:
            "Control-Option-Command--"
        case .increaseOpacity:
            "Control-Option-Command-]"
        case .decreaseOpacity:
            "Control-Option-Command-["
        case .toggleAutoScroll:
            "Control-Option-Command-P"
        case .snapToCamera:
            "Control-Option-Command-C"
        }
    }

    static func menuShortcut(for action: Action) -> MenuShortcut {
        let modifiers: SwiftUI.EventModifiers = [.command, .control, .option]

        switch action {
        case .toggleVisibility:
            return MenuShortcut(key: "o", modifiers: modifiers)
        case .toggleClickThrough:
            return MenuShortcut(key: "l", modifiers: modifiers)
        case .increaseFontSize:
            return MenuShortcut(key: "=", modifiers: modifiers)
        case .decreaseFontSize:
            return MenuShortcut(key: "-", modifiers: modifiers)
        case .increaseOpacity:
            return MenuShortcut(key: "]", modifiers: modifiers)
        case .decreaseOpacity:
            return MenuShortcut(key: "[", modifiers: modifiers)
        case .toggleAutoScroll:
            return MenuShortcut(key: "p", modifiers: modifiers)
        case .snapToCamera:
            return MenuShortcut(key: "c", modifiers: modifiers)
        }
    }

    private func registerHotkeys() {
        for action in Action.allCases {
            var hotKeyRef: EventHotKeyRef?
            let hotKeyID = EventHotKeyID(signature: Self.signature, id: action.rawValue)

            let shortcut = shortcut(for: action)
            RegisterEventHotKey(
                shortcut.keyCode,
                shortcut.modifiers,
                hotKeyID,
                GetApplicationEventTarget(),
                0,
                &hotKeyRef
            )

            hotKeyRefs.append(hotKeyRef)
        }
    }

    private func shortcut(for action: Action) -> Shortcut {
        let modifiers = UInt32(controlKey | optionKey | cmdKey)

        switch action {
        case .toggleVisibility:
            return Shortcut(keyCode: UInt32(kVK_ANSI_O), modifiers: modifiers)
        case .toggleClickThrough:
            return Shortcut(keyCode: UInt32(kVK_ANSI_L), modifiers: modifiers)
        case .increaseFontSize:
            return Shortcut(keyCode: UInt32(kVK_ANSI_Equal), modifiers: modifiers)
        case .decreaseFontSize:
            return Shortcut(keyCode: UInt32(kVK_ANSI_Minus), modifiers: modifiers)
        case .increaseOpacity:
            return Shortcut(keyCode: UInt32(kVK_ANSI_RightBracket), modifiers: modifiers)
        case .decreaseOpacity:
            return Shortcut(keyCode: UInt32(kVK_ANSI_LeftBracket), modifiers: modifiers)
        case .toggleAutoScroll:
            return Shortcut(keyCode: UInt32(kVK_ANSI_P), modifiers: modifiers)
        case .snapToCamera:
            return Shortcut(keyCode: UInt32(kVK_ANSI_C), modifiers: modifiers)
        }
    }

    private func installEventHandlerIfNeeded() {
        guard Self.shared === self else { return }

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, eventRef, _ in
                guard let eventRef else { return noErr }

                var hotKeyID = EventHotKeyID()
                let status = GetEventParameter(
                    eventRef,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )

                guard status == noErr,
                      hotKeyID.signature == HotkeyManager.signature,
                      let action = Action(rawValue: hotKeyID.id),
                      let manager = HotkeyManager.shared else {
                    return noErr
                }

                Task { @MainActor in
                    manager.handler(action)
                }

                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )
    }
}
