import AppKit
import Foundation

final class SettingsStore {
    private enum Keys {
        static let notesText = "notesText"
        static let windowOpacity = "windowOpacity"
        static let fontSize = "fontSize"
        static let autoScrollSpeed = "autoScrollSpeed"
        static let notesFontStyle = "notesFontStyle"
        static let windowFrame = "windowFrame"
        static let isClickThroughEnabled = "isClickThroughEnabled"
        static let isScreenShareExclusionEnabled = "isScreenShareExclusionEnabled"
        static let showsOnAllSpaces = "showsOnAllSpaces"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func load() -> OverlaySettings {
        OverlaySettings(
            notesText: userDefaults.string(forKey: Keys.notesText) ?? "",
            windowOpacity: loadOpacity(),
            fontSize: loadFontSize(),
            autoScrollSpeed: loadAutoScrollSpeed(),
            notesFontStyle: loadNotesFontStyle(),
            windowFrame: loadWindowFrame(),
            isClickThroughEnabled: userDefaults.bool(forKey: Keys.isClickThroughEnabled),
            isScreenShareExclusionEnabled: loadScreenShareExclusionEnabled(),
            showsOnAllSpaces: loadShowsOnAllSpaces()
        )
    }

    func saveNotes(_ notes: String) {
        userDefaults.set(notes, forKey: Keys.notesText)
    }

    func saveOpacity(_ opacity: Double) {
        userDefaults.set(clamp(opacity, min: 0.2, max: 1.0), forKey: Keys.windowOpacity)
    }

    func saveWindowFrame(_ frame: CGRect) {
        userDefaults.set(NSStringFromRect(frame), forKey: Keys.windowFrame)
    }

    func saveFontSize(_ fontSize: Double) {
        userDefaults.set(clamp(fontSize, min: 12, max: 28), forKey: Keys.fontSize)
    }

    func saveAutoScrollSpeed(_ speed: Double) {
        userDefaults.set(clamp(speed, min: 6, max: 100), forKey: Keys.autoScrollSpeed)
    }

    func saveNotesFontStyle(_ fontStyle: NotesFontStyle) {
        userDefaults.set(fontStyle.rawValue, forKey: Keys.notesFontStyle)
    }

    func saveClickThroughEnabled(_ isEnabled: Bool) {
        userDefaults.set(isEnabled, forKey: Keys.isClickThroughEnabled)
    }

    func saveScreenShareExclusionEnabled(_ isEnabled: Bool) {
        userDefaults.set(isEnabled, forKey: Keys.isScreenShareExclusionEnabled)
    }

    func saveShowsOnAllSpaces(_ showsOnAllSpaces: Bool) {
        userDefaults.set(showsOnAllSpaces, forKey: Keys.showsOnAllSpaces)
    }

    private func loadOpacity() -> Double {
        let storedOpacity = userDefaults.object(forKey: Keys.windowOpacity) as? Double ?? OverlaySettings.defaultOpacity
        return clamp(storedOpacity, min: 0.2, max: 1.0)
    }

    private func loadWindowFrame() -> CGRect {
        guard let storedFrame = userDefaults.string(forKey: Keys.windowFrame) else {
            return OverlaySettings.defaultWindowFrame
        }

        let frame = NSRectFromString(storedFrame)
        return frame.equalTo(.zero) ? OverlaySettings.defaultWindowFrame : frame
    }

    private func loadFontSize() -> Double {
        let storedFontSize = userDefaults.object(forKey: Keys.fontSize) as? Double ?? OverlaySettings.defaultFontSize
        return clamp(storedFontSize, min: 12, max: 28)
    }

    private func loadAutoScrollSpeed() -> Double {
        let storedSpeed = userDefaults.object(forKey: Keys.autoScrollSpeed) as? Double ?? OverlaySettings.defaultAutoScrollSpeed
        return clamp(storedSpeed, min: 6, max: 100)
    }

    private func loadNotesFontStyle() -> NotesFontStyle {
        guard let rawValue = userDefaults.string(forKey: Keys.notesFontStyle),
              let fontStyle = NotesFontStyle(rawValue: rawValue) else {
            return OverlaySettings.defaultNotesFontStyle
        }

        return fontStyle
    }

    private func loadScreenShareExclusionEnabled() -> Bool {
        guard userDefaults.object(forKey: Keys.isScreenShareExclusionEnabled) != nil else {
            return OverlaySettings.defaultScreenShareExclusionEnabled
        }

        return userDefaults.bool(forKey: Keys.isScreenShareExclusionEnabled)
    }

    private func loadShowsOnAllSpaces() -> Bool {
        guard userDefaults.object(forKey: Keys.showsOnAllSpaces) != nil else {
            return OverlaySettings.defaultShowsOnAllSpaces
        }

        return userDefaults.bool(forKey: Keys.showsOnAllSpaces)
    }

    private func clamp(_ value: Double, min minimum: Double, max maximum: Double) -> Double {
        Swift.min(Swift.max(value, minimum), maximum)
    }
}
