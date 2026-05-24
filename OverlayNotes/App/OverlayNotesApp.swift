import SwiftUI

@main
struct OverlayNotesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
        .commands {
            OverlayCommands()
        }
    }
}

struct OverlayCommands: Commands {
    var body: some Commands {
        CommandMenu("Overlay") {
            Button("Show or Hide Notes") {
                AppDelegate.performFromMenu(.toggleVisibility)
            }
            .keyboardShortcut(for: .toggleVisibility)

            Button("Toggle Pass-Through") {
                AppDelegate.performFromMenu(.toggleClickThrough)
            }
            .keyboardShortcut(for: .toggleClickThrough)

            Divider()

            Button("Increase Text Size") {
                AppDelegate.performFromMenu(.increaseFontSize)
            }
            .keyboardShortcut(for: .increaseFontSize)

            Button("Decrease Text Size") {
                AppDelegate.performFromMenu(.decreaseFontSize)
            }
            .keyboardShortcut(for: .decreaseFontSize)

            Divider()

            Button("Increase Opacity") {
                AppDelegate.performFromMenu(.increaseOpacity)
            }
            .keyboardShortcut(for: .increaseOpacity)

            Button("Decrease Opacity") {
                AppDelegate.performFromMenu(.decreaseOpacity)
            }
            .keyboardShortcut(for: .decreaseOpacity)
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private static weak var shared: AppDelegate?

    private var overlayWindowController: OverlayWindowController?
    private var hotkeyManager: HotkeyManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        Self.shared = self

        let settingsStore = SettingsStore()
        let controller = OverlayWindowController(settingsStore: settingsStore)

        overlayWindowController = controller
        hotkeyManager = HotkeyManager { action in
            Self.shared?.perform(action)
        }
        controller.showOverlay()

        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            overlayWindowController?.showOverlay()
        }

        return true
    }

    static func perform(_ action: HotkeyManager.Action) {
        shared?.perform(action)
    }

    static func performFromMenu(_ action: HotkeyManager.Action) {
        Task { @MainActor in
            shared?.perform(action)
        }
    }

    private func perform(_ action: HotkeyManager.Action) {
        guard let controller = overlayWindowController else { return }

        switch action {
        case .toggleVisibility:
            controller.toggleVisibility()
        case .toggleClickThrough:
            controller.toggleClickThrough()
        case .increaseFontSize:
            controller.increaseFontSize()
        case .decreaseFontSize:
            controller.decreaseFontSize()
        case .increaseOpacity:
            controller.increaseOpacity()
        case .decreaseOpacity:
            controller.decreaseOpacity()
        }
    }
}

private extension View {
    func keyboardShortcut(for action: HotkeyManager.Action) -> some View {
        let shortcut = HotkeyManager.menuShortcut(for: action)
        return keyboardShortcut(shortcut.key, modifiers: shortcut.modifiers)
    }
}
