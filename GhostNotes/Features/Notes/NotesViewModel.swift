import Foundation

@MainActor
final class NotesViewModel: ObservableObject {
    private enum Bounds {
        static let minimumOpacity = 0.2
        static let maximumOpacity = 1.0
        static let minimumFontSize = 12.0
        static let maximumFontSize = 28.0
        static let minimumAutoScrollSpeed = 6.0
        static let maximumAutoScrollSpeed = 100.0
        static let fontStep = 1.0
        static let opacityStep = 0.05
        static let autoScrollSpeedStep = 4.0
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

    @Published var autoScrollSpeed: Double {
        didSet {
            let clamped = Self.clamp(autoScrollSpeed, min: Bounds.minimumAutoScrollSpeed, max: Bounds.maximumAutoScrollSpeed)
            guard clamped == autoScrollSpeed else {
                autoScrollSpeed = clamped
                return
            }
            settingsStore.saveAutoScrollSpeed(autoScrollSpeed)
        }
    }

    @Published var notesFontStyle: NotesFontStyle {
        didSet {
            settingsStore.saveNotesFontStyle(notesFontStyle)
        }
    }

    @Published private(set) var isAutoScrollEnabled = false
    @Published private(set) var scrollResetToken = 0

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
        self.autoScrollSpeed = settings.autoScrollSpeed
        self.notesFontStyle = settings.notesFontStyle
        self.isClickThroughEnabled = settings.isClickThroughEnabled
        self.settingsStore = settingsStore
    }

    func increaseFontSize() {
        fontSize = min(fontSize + Bounds.fontStep, Bounds.maximumFontSize)
    }

    func decreaseFontSize() {
        fontSize = max(fontSize - Bounds.fontStep, Bounds.minimumFontSize)
    }

    func setNotesFontStyle(_ fontStyle: NotesFontStyle) {
        notesFontStyle = fontStyle
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

    func increaseAutoScrollSpeed() {
        autoScrollSpeed = min(autoScrollSpeed + Bounds.autoScrollSpeedStep, Bounds.maximumAutoScrollSpeed)
    }

    func decreaseAutoScrollSpeed() {
        autoScrollSpeed = max(autoScrollSpeed - Bounds.autoScrollSpeedStep, Bounds.minimumAutoScrollSpeed)
    }

    func toggleAutoScroll() {
        isAutoScrollEnabled.toggle()
    }

    func stopAutoScroll() {
        isAutoScrollEnabled = false
    }

    func resetScrollPosition() {
        isAutoScrollEnabled = false
        scrollResetToken += 1
    }

    private static func clamp(_ value: Double, min minimum: Double, max maximum: Double) -> Double {
        Swift.min(Swift.max(value, minimum), maximum)
    }
}
