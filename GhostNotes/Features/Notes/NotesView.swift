import AppKit
import SwiftUI

struct NotesView: View {
    @ObservedObject var viewModel: NotesViewModel

    private let panelCornerRadius: CGFloat = 28
    private let cardCornerRadius: CGFloat = 22
    private let sageHighlight = Color(red: 0.78, green: 0.88, blue: 0.80)
    private let sageTint = Color(red: 0.38, green: 0.56, blue: 0.45)
    private let sageShadow = Color(red: 0.18, green: 0.28, blue: 0.22)

    private var clickThroughHelpText: String {
        let shortcut = HotkeyManager.description(for: .toggleClickThrough)

        if viewModel.isClickThroughEnabled {
            return "Disable click-through (\(shortcut))"
        }

        return "Enable click-through (\(shortcut))"
    }

    private var autoScrollHelpText: String {
        let shortcut = HotkeyManager.description(for: .toggleAutoScroll)

        if viewModel.isAutoScrollEnabled {
            return "Pause auto-scroll (\(shortcut))"
        }

        return "Start auto-scroll (\(shortcut))"
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            sageHighlight.opacity(0.30),
                            Color(red: 0.88, green: 0.95, blue: 0.89).opacity(0.14)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(
                    RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    sageHighlight.opacity(0.28),
                                    Color(red: 0.93, green: 0.97, blue: 0.93).opacity(0.03)
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .padding(1)
                        .mask(
                            RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                        )
                }
                .overlay(
                    RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                        .strokeBorder(sageHighlight.opacity(0.24), lineWidth: 1)
                )
                .shadow(color: sageShadow.opacity(0.18), radius: 26, x: 0, y: 18)
                .shadow(color: sageHighlight.opacity(0.08), radius: 12, x: 0, y: 1)

            VStack(spacing: 14) {
                header

                if viewModel.isClickThroughEnabled {
                    clickThroughBanner
                }

                editorCard
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
            .padding(.top, 34)
        }
        .frame(minWidth: 420, minHeight: 220)
        .padding(10)
        .background(Color.clear)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Ghost Notes")
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text("Floating presenter overlay")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 12)

            HStack(spacing: 10) {
                autoScrollControl
                fontStyleControl
                fontSizeControl
                opacityControl
                clickThroughControl
            }
        }
        .padding(14)
        .background(glassCardBackground)
        .overlay(glassCardStroke)
    }

    private var autoScrollControl: some View {
        HStack(spacing: 8) {
            Button(action: viewModel.resetScrollPosition) {
                Image(systemName: "backward.end.fill")
            }
            .help("Reset to top")
            .buttonStyle(GlassIconButtonStyle())

            Button(action: viewModel.toggleAutoScroll) {
                Image(systemName: viewModel.isAutoScrollEnabled ? "pause.fill" : "play.fill")
            }
            .help(autoScrollHelpText)
            .buttonStyle(GlassIconButtonStyle())

            Text("Scroll")
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)

            Slider(value: $viewModel.autoScrollSpeed, in: 6 ... 100)
                .frame(width: 84)
                .help("Scroll speed")

            Text("\(Int(viewModel.autoScrollSpeed))")
                .font(.system(.caption, design: .rounded).monospacedDigit())
                .foregroundStyle(.primary)
                .frame(width: 28, alignment: .trailing)

            Text("pt/s")
                .font(.system(.caption2, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(controlChipBackground)
    }

    private var fontSizeControl: some View {
        HStack(spacing: 8) {
            Text("Text")
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)

            Button(action: viewModel.decreaseFontSize) {
                Image(systemName: "textformat.size.smaller")
            }
            .help("Smaller text (\(HotkeyManager.description(for: .decreaseFontSize)))")
            .buttonStyle(GlassIconButtonStyle())

            Text("\(Int(viewModel.fontSize)) pt")
                .font(.system(.caption, design: .rounded).monospacedDigit())
                .foregroundStyle(.primary)
                .frame(minWidth: 42, alignment: .center)

            Button(action: viewModel.increaseFontSize) {
                Image(systemName: "textformat.size.larger")
            }
            .help("Larger text (\(HotkeyManager.description(for: .increaseFontSize)))")
            .buttonStyle(GlassIconButtonStyle())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(controlChipBackground)
    }

    private var fontStyleControl: some View {
        HStack(spacing: 8) {
            Text("Font")
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)

            Picker("Font", selection: $viewModel.notesFontStyle) {
                ForEach(NotesFontStyle.allCases, id: \.self) { fontStyle in
                    Text(fontStyle.displayName).tag(fontStyle)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: 96)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(controlChipBackground)
    }

    private var opacityControl: some View {
        HStack(spacing: 8) {
            Text("Opacity")
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)

            Slider(value: $viewModel.windowOpacity, in: 0.2 ... 1.0)
                .frame(width: 92)
                .help("Adjust opacity (\(HotkeyManager.description(for: .decreaseOpacity)) / \(HotkeyManager.description(for: .increaseOpacity)))")

            Text("\(Int(viewModel.windowOpacity * 100))%")
                .font(.system(.caption, design: .rounded).monospacedDigit())
                .foregroundStyle(.primary)
                .frame(width: 38, alignment: .trailing)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(controlChipBackground)
    }

    private var clickThroughControl: some View {
        Button {
            viewModel.toggleClickThrough()
        } label: {
            HStack(spacing: 7) {
                Image(systemName: viewModel.isClickThroughEnabled ? "hand.tap.fill" : "hand.tap")
                    .imageScale(.small)

                Text("Pass-through")
                    .font(.caption.weight(.medium))
            }
            .foregroundStyle(viewModel.isClickThroughEnabled ? sageTint : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(viewModel.isClickThroughEnabled ? sageHighlight.opacity(0.18) : sageHighlight.opacity(0.08))
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(viewModel.isClickThroughEnabled ? sageTint.opacity(0.30) : sageHighlight.opacity(0.16), lineWidth: 1)
            )
        }
        .help(clickThroughHelpText)
        .buttonStyle(.plain)
    }

    private var clickThroughBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "hand.tap.fill")
                .foregroundStyle(sageTint)
                .imageScale(.medium)

            Text("Pass-through is on. Use \(HotkeyManager.description(for: .toggleClickThrough)) to interact again.")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.primary.opacity(0.85))

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(sageHighlight.opacity(0.14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(sageTint.opacity(0.22), lineWidth: 1)
        )
    }

    private var editorCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            sageHighlight.opacity(0.16),
                            Color(red: 0.88, green: 0.94, blue: 0.89).opacity(0.07)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(
                    RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                        .fill(.thinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                        .strokeBorder(sageHighlight.opacity(0.18), lineWidth: 1)
                )

            AutoScrollingTextEditor(
                text: $viewModel.notesText,
                fontSize: viewModel.fontSize,
                fontStyle: viewModel.notesFontStyle,
                isAutoScrollEnabled: viewModel.isAutoScrollEnabled,
                autoScrollSpeed: viewModel.autoScrollSpeed,
                resetToken: viewModel.scrollResetToken,
                onAutoScrollFinished: viewModel.stopAutoScroll
            )
            .padding(.horizontal, 10)
            .padding(.vertical, 10)

            if viewModel.notesText.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Paste your presenter notes here.")
                        .font(swiftUIFont(for: viewModel.notesFontStyle, size: viewModel.fontSize, weight: .medium))
                        .foregroundStyle(.primary.opacity(0.72))

                    Text("They stay local on this Mac and reopen the next time you launch the app.")
                        .font(swiftUIFont(for: viewModel.notesFontStyle, size: max(viewModel.fontSize - 2, 12), weight: .regular))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 24)
                .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var glassCardBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        sageHighlight.opacity(0.18),
                        Color(red: 0.88, green: 0.94, blue: 0.89).opacity(0.10)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.thinMaterial)
            )
    }

    private var glassCardStroke: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .strokeBorder(sageHighlight.opacity(0.18), lineWidth: 1)
    }

    private var controlChipBackground: some View {
        Capsule(style: .continuous)
            .fill(sageHighlight.opacity(0.08))
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(sageHighlight.opacity(0.14), lineWidth: 1)
            )
    }

    private func swiftUIFont(for fontStyle: NotesFontStyle, size: Double, weight: Font.Weight) -> Font {
        switch fontStyle {
        case .monospaced:
            return .system(size: size, weight: weight, design: .monospaced)
        case .rounded:
            return .system(size: size, weight: weight, design: .rounded)
        case .serif:
            return .system(size: size, weight: weight, design: .serif)
        }
    }
}

private struct AutoScrollingTextEditor: NSViewRepresentable {
    @Binding var text: String

    let fontSize: Double
    let fontStyle: NotesFontStyle
    let isAutoScrollEnabled: Bool
    let autoScrollSpeed: Double
    let resetToken: Int
    let onAutoScrollFinished: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onAutoScrollFinished: onAutoScrollFinished)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.scrollerStyle = .overlay

        let textView = NSTextView()
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.importsGraphics = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.drawsBackground = false
        textView.backgroundColor = .clear
        textView.textColor = .labelColor
        textView.insertionPointColor = .labelColor
        textView.font = nsFont(for: fontStyle, size: fontSize)
        textView.string = text
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize = NSSize(width: 0, height: 0)
        textView.autoresizingMask = [.width]
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true

        scrollView.documentView = textView
        context.coordinator.attach(scrollView: scrollView, textView: textView)

        DispatchQueue.main.async {
            scrollView.window?.makeFirstResponder(textView)
        }

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }

        if textView.string != text {
            textView.string = text
        }

        let font = nsFont(for: fontStyle, size: fontSize)
        if textView.font != font {
            textView.font = font
        }

        context.coordinator.update(
            isAutoScrollEnabled: isAutoScrollEnabled,
            autoScrollSpeed: autoScrollSpeed,
            resetToken: resetToken
        )
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        private static let autoScrollSpeedMultiplier = 0.65

        private let text: Binding<String>
        private let onAutoScrollFinished: () -> Void
        private weak var scrollView: NSScrollView?
        private weak var textView: NSTextView?
        private var timer: Timer?
        private var autoScrollSpeed = OverlaySettings.defaultAutoScrollSpeed
        private var isAutoScrollEnabled = false
        private var lastResetToken = 0

        init(text: Binding<String>, onAutoScrollFinished: @escaping () -> Void) {
            self.text = text
            self.onAutoScrollFinished = onAutoScrollFinished
        }

        func attach(scrollView: NSScrollView, textView: NSTextView) {
            self.scrollView = scrollView
            self.textView = textView
        }

        func update(isAutoScrollEnabled: Bool, autoScrollSpeed: Double, resetToken: Int) {
            self.autoScrollSpeed = autoScrollSpeed

            if resetToken != lastResetToken {
                lastResetToken = resetToken
                scrollToTop()
            }

            guard self.isAutoScrollEnabled != isAutoScrollEnabled else { return }
            self.isAutoScrollEnabled = isAutoScrollEnabled

            if isAutoScrollEnabled {
                startTimer()
            } else {
                stopTimer()
            }
        }

        func textDidChange(_ notification: Notification) {
            guard let textView else { return }
            text.wrappedValue = textView.string
        }

        private func startTimer() {
            stopTimer()

            let timer = Timer(timeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
                self?.tick()
            }

            self.timer = timer
            RunLoop.main.add(timer, forMode: .common)
        }

        private func stopTimer() {
            timer?.invalidate()
            timer = nil
        }

        private func tick() {
            guard let scrollView, let documentView = scrollView.documentView else {
                finishAutoScroll()
                return
            }

            let clipView = scrollView.contentView
            let visibleHeight = clipView.bounds.height
            let maxOffsetY = max(documentView.bounds.height - visibleHeight, 0)

            guard maxOffsetY > 0 else {
                finishAutoScroll()
                return
            }

            let currentOffsetY = clipView.bounds.origin.y
            let pointsPerFrame = autoScrollSpeed * Self.autoScrollSpeedMultiplier / 30.0
            let nextOffsetY = min(currentOffsetY + CGFloat(pointsPerFrame), maxOffsetY)

            guard nextOffsetY > currentOffsetY else {
                finishAutoScroll()
                return
            }

            clipView.setBoundsOrigin(NSPoint(x: clipView.bounds.origin.x, y: nextOffsetY))
            scrollView.reflectScrolledClipView(clipView)

            if nextOffsetY >= maxOffsetY {
                finishAutoScroll()
            }
        }

        private func scrollToTop() {
            guard let scrollView else { return }

            let clipView = scrollView.contentView
            clipView.setBoundsOrigin(.zero)
            scrollView.reflectScrolledClipView(clipView)
        }

        private func finishAutoScroll() {
            guard isAutoScrollEnabled else { return }

            isAutoScrollEnabled = false
            stopTimer()
            onAutoScrollFinished()
        }
    }

    private func nsFont(for fontStyle: NotesFontStyle, size: Double) -> NSFont {
        let baseFont = NSFont.systemFont(ofSize: size, weight: .regular)

        switch fontStyle {
        case .monospaced:
            return NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
        case .rounded:
            return font(withDesign: .rounded, basedOn: baseFont) ?? baseFont
        case .serif:
            return font(withDesign: .serif, basedOn: baseFont)
                ?? NSFont(name: "Times New Roman", size: size)
                ?? baseFont
        }
    }

    private func font(withDesign design: NSFontDescriptor.SystemDesign, basedOn font: NSFont) -> NSFont? {
        guard let descriptor = font.fontDescriptor.withDesign(design) else {
            return nil
        }

        return NSFont(descriptor: descriptor, size: font.pointSize)
    }
}

private struct GlassIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.caption, design: .rounded, weight: .semibold))
            .foregroundStyle(.primary)
            .padding(6)
            .background(
                Circle()
                    .fill(Color(red: 0.84, green: 0.92, blue: 0.85).opacity(configuration.isPressed ? 0.20 : 0.11))
            )
            .overlay(
                Circle()
                    .strokeBorder(Color(red: 0.74, green: 0.87, blue: 0.77).opacity(0.16), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.82), value: configuration.isPressed)
    }
}
