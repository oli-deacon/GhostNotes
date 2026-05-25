import Foundation

@MainActor
final class NotesViewModel: ObservableObject {
    enum ScrollStatus {
        case ready
        case scrolling
        case paused
    }

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
            onOpacityChanged?(windowOpacity)
            scheduleOpacitySave()
        }
    }

    @Published var fontSize: Double {
        didSet {
            scheduleFontSizeSave()
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
            scheduleFontStyleSave()
        }
    }

    @Published private(set) var isAutoScrollEnabled = false
    @Published private(set) var scrollResetToken = 0
    @Published private(set) var scrollStatus: ScrollStatus = .ready
    @Published private(set) var isLiveResizing = false

    @Published var isClickThroughEnabled: Bool {
        didSet {
            settingsStore.saveClickThroughEnabled(isClickThroughEnabled)
            onClickThroughChanged?(isClickThroughEnabled)
        }
    }

    @Published var isScreenShareExclusionEnabled: Bool {
        didSet {
            settingsStore.saveScreenShareExclusionEnabled(isScreenShareExclusionEnabled)
            onScreenShareExclusionChanged?(isScreenShareExclusionEnabled)
        }
    }

    var onOpacityChanged: ((Double) -> Void)?
    var onClickThroughChanged: ((Bool) -> Void)?
    var onScreenShareExclusionChanged: ((Bool) -> Void)?

    private let settingsStore: SettingsStore
    private var pendingOpacitySave: DispatchWorkItem?
    private var pendingFontSizeSave: DispatchWorkItem?
    private var pendingFontStyleSave: DispatchWorkItem?

    init(settings: OverlaySettings, settingsStore: SettingsStore) {
        self.notesText = settings.notesText
        self.windowOpacity = settings.windowOpacity
        self.fontSize = settings.fontSize
        self.autoScrollSpeed = settings.autoScrollSpeed
        self.notesFontStyle = settings.notesFontStyle
        self.isClickThroughEnabled = settings.isClickThroughEnabled
        self.isScreenShareExclusionEnabled = settings.isScreenShareExclusionEnabled
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

    func toggleScreenShareExclusion() {
        isScreenShareExclusionEnabled.toggle()
    }

    func increaseAutoScrollSpeed() {
        autoScrollSpeed = min(autoScrollSpeed + Bounds.autoScrollSpeedStep, Bounds.maximumAutoScrollSpeed)
    }

    func decreaseAutoScrollSpeed() {
        autoScrollSpeed = max(autoScrollSpeed - Bounds.autoScrollSpeedStep, Bounds.minimumAutoScrollSpeed)
    }

    func toggleAutoScroll() {
        isAutoScrollEnabled.toggle()
        scrollStatus = isAutoScrollEnabled ? .scrolling : .paused
    }

    func stopAutoScroll() {
        isAutoScrollEnabled = false
        scrollStatus = .paused
    }

    func resetScrollPosition() {
        isAutoScrollEnabled = false
        scrollResetToken += 1
        scrollStatus = .ready
    }

    func setLiveResizing(_ isLiveResizing: Bool) {
        self.isLiveResizing = isLiveResizing
    }

    private func scheduleOpacitySave() {
        pendingOpacitySave?.cancel()

        let opacity = windowOpacity
        let workItem = DispatchWorkItem { [settingsStore] in
            settingsStore.saveOpacity(opacity)
        }

        pendingOpacitySave = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: workItem)
    }

    private func scheduleFontSizeSave() {
        pendingFontSizeSave?.cancel()

        let fontSize = fontSize
        let workItem = DispatchWorkItem { [settingsStore] in
            settingsStore.saveFontSize(fontSize)
        }

        pendingFontSizeSave = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: workItem)
    }

    private func scheduleFontStyleSave() {
        pendingFontStyleSave?.cancel()

        let fontStyle = notesFontStyle
        let workItem = DispatchWorkItem { [settingsStore] in
            settingsStore.saveNotesFontStyle(fontStyle)
        }

        pendingFontStyleSave = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: workItem)
    }

    private static func clamp(_ value: Double, min minimum: Double, max maximum: Double) -> Double {
        Swift.min(Swift.max(value, minimum), maximum)
    }
}
