import AppKit
import Foundation

let fileManager = FileManager.default
let outputDirectory: URL

if CommandLine.arguments.count > 1 {
    outputDirectory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
} else {
    outputDirectory = URL(fileURLWithPath: "GhostNotes/Resources/Assets.xcassets/AppIcon.appiconset", isDirectory: true)
}

let iconSizes = [16, 32, 64, 128, 256, 512, 1024]

try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

for size in iconSizes {
    let data = try drawIcon(size: size)
    let destination = outputDirectory.appendingPathComponent("appicon-\(size).png")
    try data.write(to: destination)
}

func drawIcon(size: Int) throws -> Data {
    let dimension = CGFloat(size)
    let rect = NSRect(x: 0, y: 0, width: dimension, height: dimension)
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw NSError(domain: "GhostNotesIcon", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create bitmap context"])
    }

    bitmap.size = rect.size

    guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        throw NSError(domain: "GhostNotesIcon", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create graphics context"])
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    defer { NSGraphicsContext.restoreGraphicsState() }

    context.imageInterpolation = .high

    let backgroundPath = NSBezierPath(roundedRect: rect, xRadius: dimension * 0.24, yRadius: dimension * 0.24)
    let backgroundGradient = NSGradient(
        colors: [
            NSColor(calibratedRed: 0.88, green: 0.95, blue: 0.88, alpha: 1.0),
            NSColor(calibratedRed: 0.58, green: 0.77, blue: 0.63, alpha: 1.0)
        ]
    )!
    backgroundGradient.draw(in: backgroundPath, angle: 315)

    let haloRect = rect.insetBy(dx: dimension * 0.13, dy: dimension * 0.13)
    let haloPath = NSBezierPath(ovalIn: haloRect)
    NSColor(calibratedRed: 0.98, green: 0.99, blue: 0.95, alpha: 0.22).setFill()
    haloPath.fill()

    let ghostRect = NSRect(
        x: dimension * 0.21,
        y: dimension * 0.17,
        width: dimension * 0.58,
        height: dimension * 0.64
    )

    let shadow = NSShadow()
    shadow.shadowOffset = NSSize(width: 0, height: -dimension * 0.03)
    shadow.shadowBlurRadius = dimension * 0.08
    shadow.shadowColor = NSColor(calibratedWhite: 0.0, alpha: 0.16)
    shadow.set()

    let ghostPath = makeGhostPath(in: ghostRect)
    NSColor(calibratedRed: 0.99, green: 1.0, blue: 0.98, alpha: 0.96).setFill()
    ghostPath.fill()

    NSGraphicsContext.saveGraphicsState()
    ghostPath.addClip()

    let sheenRect = ghostRect.insetBy(dx: ghostRect.width * 0.04, dy: ghostRect.height * 0.04)
    let sheenPath = NSBezierPath(ovalIn: sheenRect.offsetBy(dx: -ghostRect.width * 0.1, dy: ghostRect.height * 0.1))
    NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.34).setFill()
    sheenPath.fill()

    NSGraphicsContext.restoreGraphicsState()

    NSColor(calibratedRed: 0.46, green: 0.63, blue: 0.51, alpha: 0.55).setStroke()
    ghostPath.lineWidth = max(1.0, dimension * 0.016)
    ghostPath.stroke()

    let eyeRadius = dimension * 0.033
    let leftEyeCenter = NSPoint(x: ghostRect.midX - dimension * 0.07, y: ghostRect.midY + dimension * 0.07)
    let rightEyeCenter = NSPoint(x: ghostRect.midX + dimension * 0.07, y: ghostRect.midY + dimension * 0.07)

    for center in [leftEyeCenter, rightEyeCenter] {
        let eyeRect = NSRect(
            x: center.x - eyeRadius,
            y: center.y - eyeRadius,
            width: eyeRadius * 2,
            height: eyeRadius * 2.3
        )
        let eyePath = NSBezierPath(roundedRect: eyeRect, xRadius: eyeRadius, yRadius: eyeRadius)
        NSColor(calibratedRed: 0.23, green: 0.35, blue: 0.28, alpha: 0.92).setFill()
        eyePath.fill()
    }

    let lineColor = NSColor(calibratedRed: 0.46, green: 0.67, blue: 0.53, alpha: 0.85)
    let lineWidth = max(1.2, dimension * 0.018)
    let startX = ghostRect.minX + ghostRect.width * 0.2
    let maxWidth = ghostRect.width * 0.6
    let lineYs = [
        ghostRect.midY - ghostRect.height * 0.03,
        ghostRect.midY - ghostRect.height * 0.15,
        ghostRect.midY - ghostRect.height * 0.27
    ]

    for (index, y) in lineYs.enumerated() {
        let inset = CGFloat(index) * ghostRect.width * 0.07
        let linePath = NSBezierPath()
        linePath.move(to: NSPoint(x: startX, y: y))
        linePath.line(to: NSPoint(x: startX + maxWidth - inset, y: y))
        linePath.lineCapStyle = .round
        linePath.lineWidth = lineWidth
        lineColor.setStroke()
        linePath.stroke()
    }

    guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "GhostNotesIcon", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create PNG data"])
    }

    return pngData
}

func makeGhostPath(in rect: NSRect) -> NSBezierPath {
    let path = NSBezierPath()
    let midX = rect.midX
    let maxX = rect.maxX
    let minX = rect.minX
    let maxY = rect.maxY
    let minY = rect.minY
    let waveHeight = rect.height * 0.16

    path.move(to: NSPoint(x: minX, y: minY + waveHeight))
    path.curve(
        to: NSPoint(x: midX, y: maxY),
        controlPoint1: NSPoint(x: minX, y: rect.midY + rect.height * 0.33),
        controlPoint2: NSPoint(x: minX + rect.width * 0.18, y: maxY)
    )
    path.curve(
        to: NSPoint(x: maxX, y: minY + waveHeight),
        controlPoint1: NSPoint(x: maxX - rect.width * 0.18, y: maxY),
        controlPoint2: NSPoint(x: maxX, y: rect.midY + rect.height * 0.33)
    )
    path.curve(
        to: NSPoint(x: maxX - rect.width * 0.18, y: minY + waveHeight * 0.54),
        controlPoint1: NSPoint(x: maxX, y: minY + waveHeight * 0.52),
        controlPoint2: NSPoint(x: maxX - rect.width * 0.06, y: minY)
    )
    path.curve(
        to: NSPoint(x: midX + rect.width * 0.1, y: minY + waveHeight),
        controlPoint1: NSPoint(x: maxX - rect.width * 0.28, y: minY + waveHeight * 1.1),
        controlPoint2: NSPoint(x: midX + rect.width * 0.2, y: minY + waveHeight * 0.22)
    )
    path.curve(
        to: NSPoint(x: midX - rect.width * 0.1, y: minY + waveHeight),
        controlPoint1: NSPoint(x: midX + rect.width * 0.04, y: minY + waveHeight * 1.75),
        controlPoint2: NSPoint(x: midX - rect.width * 0.04, y: minY + waveHeight * 1.75)
    )
    path.curve(
        to: NSPoint(x: minX + rect.width * 0.18, y: minY + waveHeight * 0.54),
        controlPoint1: NSPoint(x: midX - rect.width * 0.2, y: minY + waveHeight * 0.22),
        controlPoint2: NSPoint(x: minX + rect.width * 0.28, y: minY + waveHeight * 1.1)
    )
    path.curve(
        to: NSPoint(x: minX, y: minY + waveHeight),
        controlPoint1: NSPoint(x: minX + rect.width * 0.06, y: minY),
        controlPoint2: NSPoint(x: minX, y: minY + waveHeight * 0.52)
    )
    path.close()

    return path
}
