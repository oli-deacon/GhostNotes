import CoreGraphics

enum NotesFontStyle: String, CaseIterable {
    case monospaced
    case rounded
    case serif

    var displayName: String {
        switch self {
        case .monospaced:
            return "Mono"
        case .rounded:
            return "Rounded"
        case .serif:
            return "Serif"
        }
    }
}

struct OverlaySettings {
    static let defaultOpacity = 0.75
    static let launchOpacity = 0.75
    static let defaultFontSize = 15.0
    static let defaultAutoScrollSpeed = 20.0
    static let defaultNotesFontStyle: NotesFontStyle = .monospaced
    static let defaultWindowFrame = CGRect(x: 240, y: 240, width: 560, height: 360)
    static let defaultScreenShareExclusionEnabled = true

    var notesText: String
    var windowOpacity: Double
    var fontSize: Double
    var autoScrollSpeed: Double
    var notesFontStyle: NotesFontStyle
    var windowFrame: CGRect
    var isClickThroughEnabled: Bool
    var isScreenShareExclusionEnabled: Bool
}
