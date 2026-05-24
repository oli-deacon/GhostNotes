import CoreGraphics

struct OverlaySettings {
    static let defaultOpacity = 0.9
    static let defaultFontSize = 15.0
    static let defaultWindowFrame = CGRect(x: 240, y: 240, width: 560, height: 360)

    var notesText: String
    var windowOpacity: Double
    var fontSize: Double
    var windowFrame: CGRect
    var isClickThroughEnabled: Bool
}
