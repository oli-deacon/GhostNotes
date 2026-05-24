import Foundation

@MainActor
final class NotesViewModel: ObservableObject {
    private enum Bounds {
        static let minimumOpacity = 0.2
        static let maximumOpacity = 1.0
        static let minimumFontSize = 12.0
        static let maximumFontSize = 28.0
        static let fontStep = 1.0
        static let opacityStep = 0.05
    }

    @Published var notesText: String {
        didSet {
            settingsStore.saveNotes(notesText)
        }
    }

    @Published var windowOpacity: Double {
        didSet {
            settingsStore.saveOpacity(windowOpacity)
            onOpacityChanged?(windowOpacity)
        }
    }

    @Published var fontSize: Double {
        didSet {
            settingsStore.saveFontSize(fontSize)
        }
    }

    @Published var isClickThroughEnabled: Bool {
        didSet {
            settingsStore.saveClickThroughEnabled(isClickThroughEnabled)
            onClickThroughChanged?(isClickThroughEnabled)
        }
    }

    var onOpacityChanged: ((Double) -> Void)?
    var onClickThroughChanged: ((Bool) -> Void)?

    private let settingsStore: SettingsStore

    init(settings: OverlaySettings, settingsStore: SettingsStore) {
        self.notesText = settings.notesText
        self.windowOpacity = settings.windowOpacity
        self.fontSize = settings.fontSize
        self.isClickThroughEnabled = settings.isClickThroughEnabled
        self.settingsStore = settingsStore
    }

    func increaseFontSize() {
        fontSize = min(fontSize + Bounds.fontStep, Bounds.maximumFontSize)
    }

    func decreaseFontSize() {
        fontSize = max(fontSize - Bounds.fontStep, Bounds.minimumFontSize)
    }

    func increaseOpacity() {
        windowOpacity = min(windowOpacity + Bounds.opacityStep, Bounds.maximumOpacity)
    }

    func decreaseOpacity() {
        windowOpacity = max(windowOpacity - Bounds.opacityStep, Bounds.minimumOpacity)
    }

    func toggleClickThrough() {
        isClickThroughEnabled.toggle()
    }
}
