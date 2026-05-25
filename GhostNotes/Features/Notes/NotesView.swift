import AppKit
import SwiftUI

struct NotesView: View {
    @ObservedObject var viewModel: NotesViewModel

    var body: some View {
        ZStack {
            shellBackground

            VStack(spacing: SoftStudioTheme.spacingMedium) {
                header

                if viewModel.isClickThroughEnabled {
                    clickThroughBanner
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                if viewModel.isScreenShareExclusionEnabled {
                    screenShareExclusionBanner
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                if !viewModel.showsOnAllSpaces {
                    allSpacesBanner
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                editorCard
            }
            .padding(.horizontal, SoftStudioTheme.spacingMedium)
            .padding(.bottom, SoftStudioTheme.spacingMedium)
            .padding(.top, 34)
        }
        .frame(minWidth: 420, minHeight: 220)
        .padding(10)
        .background(Color.clear)
    }

    private var shellBackground: some View {
        let shape = RoundedRectangle(cornerRadius: SoftStudioTheme.cornerShell, style: .continuous)
        let isLiveResizing = viewModel.isLiveResizing

        return shape
            .fill(SoftStudioTheme.shellWash)
            .background {
                if isLiveResizing {
                    shape.fill(SoftStudioTheme.backgroundWash.opacity(0.18))
                } else {
                    shape.fill(.ultraThinMaterial)
                }
            }
            .overlay {
                if !isLiveResizing {
                    shape
                        .fill(SoftStudioTheme.shellInnerGlow)
                        .blur(radius: 0.6)
                        .padding(1)
                        .mask(shape)
                }
            }
            .overlay(alignment: .top) {
                shape
                    .fill(SoftStudioTheme.shellTopHighlight)
                    .padding(1)
                    .mask(shape)
            }
            .overlay {
                shape
                    .strokeBorder(SoftStudioTheme.shellStroke, lineWidth: 1)
            }
            .overlay {
                if viewModel.isAutoScrollEnabled && !isLiveResizing {
                    shape
                        .strokeBorder(SoftStudioTheme.autoScrollGlow, lineWidth: 1.2)
                        .opacity(0.22)
                }
            }
            .shadow(color: SoftStudioTheme.shadowStrong, radius: isLiveResizing ? 12 : 28, x: 0, y: isLiveResizing ? 8 : 20)
            .shadow(color: SoftStudioTheme.shadowSoft, radius: isLiveResizing ? 4 : 12, x: 0, y: 2)
    }

    private var header: some View {
        ViewThatFits(in: .horizontal) {
            headerSingleRow
            headerTwoRow
        }
        .padding(14)
        .background(
            SoftStudioCardBackground(
                cornerRadius: SoftStudioTheme.cornerCard,
                fill: SoftStudioTheme.headerFill,
                highlight: SoftStudioTheme.headerHighlight,
                stroke: SoftStudioTheme.headerStroke
            )
        )
    }

    private var headerSingleRow: some View {
        HStack(alignment: .top, spacing: 14) {
            headerTitle

            Spacer(minLength: 10)

            HStack(spacing: SoftStudioTheme.spacingSmall) {
                autoScrollControl
                fontStyleControl
                fontSizeControl
                opacityControl
                allSpacesControl
                screenShareExclusionControl
                clickThroughControl
            }
        }
    }

    private var headerTwoRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                headerTitle
                Spacer(minLength: 0)
                compactClickThroughControl
            }

            HStack(alignment: .center, spacing: 8) {
                autoScrollControl
                fontStyleControl
                fontSizeControl
                Spacer(minLength: 0)
            }

            HStack(alignment: .center, spacing: 8) {
                opacityControl
                allSpacesControl
                screenShareExclusionControl
                Spacer(minLength: 0)
            }
        }
    }

    private var headerTitle: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 10) {
                WindowDragHandle()

                HStack(spacing: 8) {
                    Circle()
                        .fill(viewModel.isAutoScrollEnabled ? SoftStudioTheme.accent : SoftStudioTheme.accentMuted)
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                        )
                        .shadow(color: viewModel.isAutoScrollEnabled ? SoftStudioTheme.accent.opacity(0.30) : .clear, radius: 6)

                    Text("Ghost Notes")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundStyle(SoftStudioTheme.textPrimary)
                        .lineLimit(1)
                }
            }

            Text(statusSubtitle)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(SoftStudioTheme.textSecondary)
        }
    }

    private var autoScrollControl: some View {
        SoftStudioChip(isActive: viewModel.isAutoScrollEnabled, minHeight: 40) {
            ViewThatFits(in: .horizontal) {
                autoScrollControlContent(label: "Scroll", sliderWidth: 84, showUnit: true)
                autoScrollControlContent(label: "Scroll", sliderWidth: 72, showUnit: false)
                autoScrollControlContent(label: "Scr", sliderWidth: 60, showUnit: false)
            }
        }
    }

    private var fontSizeControl: some View {
        SoftStudioChip(minHeight: 40) {
            ViewThatFits(in: .horizontal) {
                fontSizeControlContent(label: "Text", showUnit: true)
                fontSizeControlContent(label: "Text", showUnit: false)
                fontSizeControlContent(label: "", showUnit: false)
            }
        }
    }

    private var fontStyleControl: some View {
        SoftStudioChip(minHeight: 40) {
            ViewThatFits(in: .horizontal) {
                fontStyleControlContent(label: "Font", pickerWidth: 96)
                fontStyleControlContent(label: "", pickerWidth: 84)
                fontStyleControlContent(label: "", pickerWidth: 72)
            }
        }
    }

    private var opacityControl: some View {
        SoftStudioChip(minHeight: 40) {
            ViewThatFits(in: .horizontal) {
                opacityControlContent(label: "Opacity", sliderWidth: 92, showPercentSymbol: true)
                opacityControlContent(label: "Opacity", sliderWidth: 78, showPercentSymbol: false)
                opacityControlContent(label: "", sliderWidth: 64, showPercentSymbol: false)
            }
        }
    }

    private var clickThroughControl: some View {
        Button {
            viewModel.toggleClickThrough()
        } label: {
            HStack(spacing: 7) {
                Image(systemName: viewModel.isClickThroughEnabled ? "hand.tap.fill" : "hand.tap")
                    .imageScale(.small)

                ViewThatFits(in: .horizontal) {
                    Text("Pass-through")
                    Text("Pass")
                    Text("PT")
                }
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .help(clickThroughHelpText)
        .buttonStyle(SoftStudioToggleButtonStyle(isActive: viewModel.isClickThroughEnabled))
    }

    private var screenShareExclusionControl: some View {
        Button {
            viewModel.toggleScreenShareExclusion()
        } label: {
            HStack(spacing: 7) {
                Image(systemName: viewModel.isScreenShareExclusionEnabled ? "rectangle.slash.fill" : "rectangle.on.rectangle")
                    .imageScale(.small)

                ViewThatFits(in: .horizontal) {
                    Text("Hide on Share")
                    Text("Hide Share")
                    Text("Hide")
                }
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .help(screenShareExclusionHelpText)
        .buttonStyle(SoftStudioToggleButtonStyle(isActive: viewModel.isScreenShareExclusionEnabled))
    }

    private var allSpacesControl: some View {
        Button {
            viewModel.toggleShowsOnAllSpaces()
        } label: {
            HStack(spacing: 7) {
                Image(systemName: viewModel.showsOnAllSpaces ? "square.3.stack.3d.top.filled" : "display")
                    .imageScale(.small)

                ViewThatFits(in: .horizontal) {
                    Text("All Spaces")
                    Text("All")
                }
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .help(allSpacesHelpText)
        .buttonStyle(SoftStudioToggleButtonStyle(isActive: viewModel.showsOnAllSpaces))
    }

    private var compactClickThroughControl: some View {
        Button {
            viewModel.toggleClickThrough()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: viewModel.isClickThroughEnabled ? "hand.tap.fill" : "hand.tap")
                    .imageScale(.small)

                ViewThatFits(in: .horizontal) {
                    Text("Pass-through")
                    Text("Pass")
                    Text("PT")
                }
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .help(clickThroughHelpText)
        .buttonStyle(SoftStudioToggleButtonStyle(isActive: viewModel.isClickThroughEnabled))
    }

    private var clickThroughBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "hand.tap.fill")
                .foregroundStyle(SoftStudioTheme.accent)
                .imageScale(.medium)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text("Pass-through is on")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(SoftStudioTheme.textPrimary)

                Text("Use \(HotkeyManager.description(for: .toggleClickThrough)) to interact with Ghost Notes again.")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(SoftStudioTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            SoftStudioCardBackground(
                cornerRadius: SoftStudioTheme.cornerChip,
                fill: SoftStudioTheme.bannerFill,
                highlight: SoftStudioTheme.bannerHighlight,
                stroke: SoftStudioTheme.bannerStroke
            )
        )
    }

    private var screenShareExclusionBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "rectangle.slash.fill")
                .foregroundStyle(SoftStudioTheme.accent)
                .imageScale(.medium)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text("Hide on Share is on")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(SoftStudioTheme.textPrimary)

                Text("Ghost Notes asks macOS to hide this window during screen sharing and recording, but some apps may still capture it.")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(SoftStudioTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            SoftStudioCardBackground(
                cornerRadius: SoftStudioTheme.cornerChip,
                fill: SoftStudioTheme.bannerFill,
                highlight: SoftStudioTheme.bannerHighlight,
                stroke: SoftStudioTheme.bannerStroke
            )
        )
    }

    private var allSpacesBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "display")
                .foregroundStyle(SoftStudioTheme.accent)
                .imageScale(.medium)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text("Single-display mode is on")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(SoftStudioTheme.textPrimary)

                Text("Ghost Notes stays on its current display and space. This is the most reliable way to keep it off a shared screen in Zoom or Teams.")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(SoftStudioTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            SoftStudioCardBackground(
                cornerRadius: SoftStudioTheme.cornerChip,
                fill: SoftStudioTheme.bannerFill,
                highlight: SoftStudioTheme.bannerHighlight,
                stroke: SoftStudioTheme.bannerStroke
            )
        )
    }

    private var editorCard: some View {
        ZStack(alignment: .topLeading) {
            SoftStudioCardBackground(
                cornerRadius: SoftStudioTheme.cornerEditor,
                fill: SoftStudioTheme.editorFill,
                highlight: SoftStudioTheme.editorHighlight,
                stroke: SoftStudioTheme.editorStroke
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
            .padding(.horizontal, 14)
            .padding(.vertical, 14)

            focusBandOverlay
                .padding(.horizontal, 18)
                .padding(.vertical, 18)
                .opacity(viewModel.isAutoScrollEnabled ? 1 : 0)
                .allowsHitTesting(false)

            if viewModel.notesText.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Settle your notes here before you go on stage.")
                        .font(swiftUIFont(for: viewModel.notesFontStyle, size: viewModel.fontSize + 2, weight: .medium))
                        .foregroundStyle(SoftStudioTheme.textPrimary.opacity(0.84))

                    Text("Everything stays on this Mac, and your notes will be waiting when you open Ghost Notes again.")
                        .font(swiftUIFont(for: viewModel.notesFontStyle, size: max(viewModel.fontSize - 1, 12), weight: .regular))
                        .foregroundStyle(SoftStudioTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 28)
                .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var focusBandOverlay: some View {
        VStack {
            Spacer(minLength: 0)

            SoftStudioFocusBand()
                .frame(height: focusBandHeight)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: SoftStudioTheme.cornerEditor - 8, style: .continuous))
    }

    private var focusBandHeight: CGFloat {
        let baseHeight = CGFloat(viewModel.fontSize * 2.35)
        return min(max(baseHeight, 52), 86)
    }

    private var clickThroughHelpText: String {
        let shortcut = HotkeyManager.description(for: .toggleClickThrough)
        return viewModel.isClickThroughEnabled
            ? "Disable click-through (\(shortcut))"
            : "Enable click-through (\(shortcut))"
    }

    private var screenShareExclusionHelpText: String {
        viewModel.isScreenShareExclusionEnabled
            ? "Best-effort hiding from screen sharing and recording is enabled"
            : "Enable best-effort hiding from screen sharing and recording"
    }

    private var allSpacesHelpText: String {
        viewModel.showsOnAllSpaces
            ? "Ghost Notes appears across spaces and full-screen apps"
            : "Ghost Notes stays on its current display and space"
    }

    private var autoScrollHelpText: String {
        let shortcut = HotkeyManager.description(for: .toggleAutoScroll)
        return viewModel.isAutoScrollEnabled
            ? "Pause auto-scroll (\(shortcut))"
            : "Start auto-scroll (\(shortcut))"
    }

    private var statusSubtitle: String {
        if viewModel.isClickThroughEnabled {
            return "Pass-through enabled"
        }

        if !viewModel.showsOnAllSpaces {
            return "Single-display mode"
        }

        switch viewModel.scrollStatus {
        case .ready:
            return "Ready to present"
        case .scrolling:
            return "Auto-scroll on"
        case .paused:
            return "Paused at current position"
        }
    }

    private func autoScrollControlContent(label: String, sliderWidth: CGFloat, showUnit: Bool) -> some View {
        HStack(spacing: 8) {
            Button(action: viewModel.resetScrollPosition) {
                Image(systemName: "backward.end.fill")
            }
            .help("Reset to top")
            .buttonStyle(SoftStudioIconButtonStyle())

            Button(action: viewModel.toggleAutoScroll) {
                Image(systemName: viewModel.isAutoScrollEnabled ? "pause.fill" : "play.fill")
            }
            .help(autoScrollHelpText)
            .buttonStyle(SoftStudioIconButtonStyle(isActive: viewModel.isAutoScrollEnabled))

            Text(label)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(SoftStudioTheme.textSecondary)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)

            Slider(value: $viewModel.autoScrollSpeed, in: 6 ... 100)
                .frame(width: sliderWidth)
                .tint(SoftStudioTheme.accent)
                .help("Scroll speed")

            Text("\(Int(viewModel.autoScrollSpeed))")
                .font(.system(.caption, design: .rounded).monospacedDigit())
                .foregroundStyle(SoftStudioTheme.textPrimary)
                .frame(width: 28, alignment: .trailing)

            if showUnit {
                Text("pt/s")
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .foregroundStyle(SoftStudioTheme.textSecondary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
    }

    private func fontSizeControlContent(label: String, showUnit: Bool) -> some View {
        HStack(spacing: 8) {
            if !label.isEmpty {
                Text(label)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(SoftStudioTheme.textSecondary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }

            Button(action: viewModel.decreaseFontSize) {
                Image(systemName: "textformat.size.smaller")
            }
            .help("Smaller text (\(HotkeyManager.description(for: .decreaseFontSize)))")
            .buttonStyle(SoftStudioIconButtonStyle())

            Text(showUnit ? "\(Int(viewModel.fontSize)) pt" : "\(Int(viewModel.fontSize))")
                .font(.system(.caption, design: .rounded).monospacedDigit())
                .foregroundStyle(SoftStudioTheme.textPrimary)
                .frame(minWidth: showUnit ? 42 : 24, alignment: .center)
                .lineLimit(1)

            Button(action: viewModel.increaseFontSize) {
                Image(systemName: "textformat.size.larger")
            }
            .help("Larger text (\(HotkeyManager.description(for: .increaseFontSize)))")
            .buttonStyle(SoftStudioIconButtonStyle())
        }
    }

    private func fontStyleControlContent(label: String, pickerWidth: CGFloat) -> some View {
        HStack(spacing: 8) {
            if !label.isEmpty {
                Text(label)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(SoftStudioTheme.textSecondary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }

            Picker("Font", selection: $viewModel.notesFontStyle) {
                ForEach(NotesFontStyle.allCases, id: \.self) { fontStyle in
                    Text(fontStyle.displayName).tag(fontStyle)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: pickerWidth)
        }
    }

    private func opacityControlContent(label: String, sliderWidth: CGFloat, showPercentSymbol: Bool) -> some View {
        HStack(spacing: 8) {
            if !label.isEmpty {
                Text(label)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(SoftStudioTheme.textSecondary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }

            Slider(value: $viewModel.windowOpacity, in: 0.2 ... 1.0)
                .frame(width: sliderWidth)
                .tint(SoftStudioTheme.accent)
                .help("Adjust opacity (\(HotkeyManager.description(for: .decreaseOpacity)) / \(HotkeyManager.description(for: .increaseOpacity)))")

            Text(showPercentSymbol ? "\(Int(viewModel.windowOpacity * 100))%" : "\(Int(viewModel.windowOpacity * 100))")
                .font(.system(.caption, design: .rounded).monospacedDigit())
                .foregroundStyle(SoftStudioTheme.textPrimary)
                .frame(width: showPercentSymbol ? 38 : 24, alignment: .trailing)
                .lineLimit(1)
        }
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
        Coordinator(
            text: $text,
            initialFontSize: fontSize,
            initialFontStyle: fontStyle,
            onAutoScrollFinished: onAutoScrollFinished
        )
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
        textView.textColor = SoftStudioThemeNS.textPrimary
        textView.insertionPointColor = SoftStudioThemeNS.textPrimary
        textView.usesFontPanel = false
        textView.layoutManager?.allowsNonContiguousLayout = true
        textView.layoutManager?.usesFontLeading = false
        textView.string = text
        textView.textContainerInset = NSSize(width: 14, height: 16)
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize = NSSize(width: 0, height: 0)
        textView.autoresizingMask = [.width]
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.lineFragmentPadding = 0
        context.coordinator.applyTypographyIfNeeded(to: textView, fontSize: fontSize, fontStyle: fontStyle, forceTextStorageStyling: true)

        scrollView.documentView = textView
        context.coordinator.attach(scrollView: scrollView, textView: textView)

        DispatchQueue.main.async {
            scrollView.window?.makeFirstResponder(textView)
        }

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        var shouldRestyleTextStorage = false

        if textView.string != text {
            textView.string = text
            shouldRestyleTextStorage = true
        }

        context.coordinator.applyTypographyIfNeeded(
            to: textView,
            fontSize: fontSize,
            fontStyle: fontStyle,
            forceTextStorageStyling: shouldRestyleTextStorage
        )

        context.coordinator.update(
            isAutoScrollEnabled: isAutoScrollEnabled,
            autoScrollSpeed: autoScrollSpeed,
            resetToken: resetToken
        )
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        private struct TypographyState: Equatable {
            let fontStyle: NotesFontStyle
            let fontSize: Double
        }

        private static let autoScrollSpeedMultiplier = 0.65

        private let text: Binding<String>
        private let onAutoScrollFinished: () -> Void
        private weak var scrollView: NSScrollView?
        private weak var textView: NSTextView?
        private var timer: Timer?
        private var autoScrollSpeed = OverlaySettings.defaultAutoScrollSpeed
        private var isAutoScrollEnabled = false
        private var lastResetToken = 0
        private var lastTypographyState: TypographyState?

        init(
            text: Binding<String>,
            initialFontSize: Double,
            initialFontStyle: NotesFontStyle,
            onAutoScrollFinished: @escaping () -> Void
        ) {
            self.text = text
            self.lastTypographyState = TypographyState(fontStyle: initialFontStyle, fontSize: initialFontSize)
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

        func applyTypographyIfNeeded(
            to textView: NSTextView,
            fontSize: Double,
            fontStyle: NotesFontStyle,
            forceTextStorageStyling: Bool
        ) {
            let nextState = TypographyState(fontStyle: fontStyle, fontSize: fontSize)
            let didTypographyChange = lastTypographyState != nextState

            guard didTypographyChange || forceTextStorageStyling else { return }

            let font = AutoScrollingTextEditor.nsFont(for: fontStyle, size: fontSize + 1)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.18
            paragraphStyle.paragraphSpacing = 7

            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: SoftStudioThemeNS.textPrimary,
                .paragraphStyle: paragraphStyle
            ]

            textView.font = font
            textView.textColor = SoftStudioThemeNS.textPrimary
            textView.insertionPointColor = SoftStudioThemeNS.textPrimary
            textView.defaultParagraphStyle = paragraphStyle
            textView.typingAttributes = attributes

            if didTypographyChange || forceTextStorageStyling {
                if let textStorage = textView.textStorage {
                    let selectedRange = textView.selectedRange()
                    let fullRange = NSRange(location: 0, length: textStorage.length)
                    let undoManager = textView.undoManager

                    undoManager?.disableUndoRegistration()
                    textStorage.beginEditing()
                    if fullRange.length > 0 {
                        textStorage.setAttributes(attributes, range: fullRange)
                    }
                    textStorage.endEditing()
                    undoManager?.enableUndoRegistration()
                    textView.setSelectedRange(selectedRange)
                }
            }

            lastTypographyState = nextState
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

    private static func nsFont(for fontStyle: NotesFontStyle, size: Double) -> NSFont {
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

    private static func font(withDesign design: NSFontDescriptor.SystemDesign, basedOn font: NSFont) -> NSFont? {
        guard let descriptor = font.fontDescriptor.withDesign(design) else {
            return nil
        }

        return NSFont(descriptor: descriptor, size: font.pointSize)
    }
}

private enum SoftStudioTheme {
    static let backgroundWash = Color(red: 0.92, green: 0.96, blue: 0.93)
    static let glassFill = Color(red: 0.97, green: 0.99, blue: 0.97)
    static let cardFill = Color(red: 0.94, green: 0.97, blue: 0.94)
    static let accent = Color(red: 0.35, green: 0.56, blue: 0.46)
    static let accentMuted = Color(red: 0.66, green: 0.76, blue: 0.70)
    static let textPrimary = Color(red: 0.16, green: 0.23, blue: 0.20)
    static let textSecondary = Color(red: 0.36, green: 0.46, blue: 0.40)
    static let shadowStrong = Color.black.opacity(0.14)
    static let shadowSoft = Color.black.opacity(0.05)

    static let cornerShell: CGFloat = 30
    static let cornerCard: CGFloat = 24
    static let cornerEditor: CGFloat = 26
    static let cornerChip: CGFloat = 18

    static let spacingSmall: CGFloat = 10
    static let spacingMedium: CGFloat = 14

    static let shellWash = LinearGradient(
        colors: [
            backgroundWash.opacity(0.64),
            glassFill.opacity(0.16)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let shellInnerGlow = LinearGradient(
        colors: [
            Color.white.opacity(0.20),
            accentMuted.opacity(0.04)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let shellTopHighlight = LinearGradient(
        colors: [
            Color.white.opacity(0.34),
            Color.white.opacity(0.04)
        ],
        startPoint: .top,
        endPoint: .center
    )

    static let shellStroke = accentMuted.opacity(0.22)
    static let autoScrollGlow = accent.opacity(0.50)

    static let headerFill = LinearGradient(
        colors: [
            glassFill.opacity(0.84),
            backgroundWash.opacity(0.46)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let headerHighlight = LinearGradient(
        colors: [
            Color.white.opacity(0.28),
            accentMuted.opacity(0.04)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let headerStroke = accentMuted.opacity(0.20)

    static let editorFill = LinearGradient(
        colors: [
            cardFill.opacity(0.86),
            Color.white.opacity(0.80)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let editorHighlight = LinearGradient(
        colors: [
            Color.white.opacity(0.36),
            accentMuted.opacity(0.02)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let editorStroke = accentMuted.opacity(0.16)

    static let bannerFill = LinearGradient(
        colors: [
            accent.opacity(0.12),
            cardFill.opacity(0.52)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let bannerHighlight = LinearGradient(
        colors: [
            Color.white.opacity(0.22),
            accentMuted.opacity(0.03)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let bannerStroke = accent.opacity(0.24)

    static let chipFill = LinearGradient(
        colors: [
            Color.white.opacity(0.22),
            backgroundWash.opacity(0.24)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let chipActiveFill = LinearGradient(
        colors: [
            accent.opacity(0.14),
            glassFill.opacity(0.30)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let focusBandFill = LinearGradient(
        colors: [
            accent.opacity(0.03),
            accent.opacity(0.11),
            Color.white.opacity(0.18),
            accent.opacity(0.11),
            accent.opacity(0.03)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let focusBandFeather = LinearGradient(
        stops: [
            .init(color: .clear, location: 0),
            .init(color: accent.opacity(0.10), location: 0.24),
            .init(color: accent.opacity(0.18), location: 0.5),
            .init(color: accent.opacity(0.10), location: 0.76),
            .init(color: .clear, location: 1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let focusBandStroke = accent.opacity(0.18)
    static let focusBandGlow = accent.opacity(0.10)
}

private enum SoftStudioThemeNS {
    static let textPrimary = NSColor(calibratedRed: 0.16, green: 0.23, blue: 0.20, alpha: 1.0)
}

private struct SoftStudioCardBackground: View {
    let cornerRadius: CGFloat
    let fill: LinearGradient
    let highlight: LinearGradient
    let stroke: Color

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        shape
            .fill(fill)
            .background(shape.fill(.thinMaterial))
            .overlay {
                shape
                    .fill(highlight)
                    .padding(1)
                    .mask(shape)
            }
            .overlay {
                shape.strokeBorder(stroke, lineWidth: 1)
            }
    }
}

private struct WindowDragHandle: View {
    var body: some View {
        ZStack {
            WindowDragHandleRepresentable()

            Image(systemName: "circle.grid.2x2.fill")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(SoftStudioTheme.textSecondary.opacity(0.9))
        }
        .frame(width: 34, height: 26)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(SoftStudioTheme.cardFill.opacity(0.72))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(SoftStudioTheme.headerStroke.opacity(0.8), lineWidth: 1)
        )
        .help("Drag to move window")
    }
}

private struct WindowDragHandleRepresentable: NSViewRepresentable {
    func makeNSView(context: Context) -> DragHandleNSView {
        DragHandleNSView()
    }

    func updateNSView(_ nsView: DragHandleNSView, context: Context) {}
}

private final class DragHandleNSView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        translatesAutoresizingMaskIntoConstraints = false
        toolTip = "Drag to move window"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: 34, height: 26)
    }

    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
}

private struct SoftStudioChip<Content: View>: View {
    let isActive: Bool
    let minHeight: CGFloat
    @ViewBuilder let content: Content

    init(
        isActive: Bool = false,
        minHeight: CGFloat = 36,
        @ViewBuilder content: () -> Content
    ) {
        self.isActive = isActive
        self.minHeight = minHeight
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(minHeight: minHeight)
            .background(background)
            .shadow(color: isActive ? SoftStudioTheme.accent.opacity(0.10) : .clear, radius: 8, y: 2)
    }

    private var background: some View {
        Capsule(style: .continuous)
            .fill(isActive ? SoftStudioTheme.chipActiveFill : SoftStudioTheme.chipFill)
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(
                        isActive ? SoftStudioTheme.accent.opacity(0.24) : SoftStudioTheme.accentMuted.opacity(0.18),
                        lineWidth: 1
                    )
            )
    }
}

private struct SoftStudioFocusBand: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(SoftStudioTheme.focusBandFill)
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(SoftStudioTheme.focusBandFeather)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(SoftStudioTheme.focusBandStroke, lineWidth: 1)
            }
            .shadow(color: SoftStudioTheme.focusBandGlow, radius: 14, x: 0, y: 0)
            .blendMode(.plusLighter)
            .accessibilityHidden(true)
    }
}

private struct SoftStudioIconButtonStyle: ButtonStyle {
    var isActive = false

    func makeBody(configuration: Configuration) -> some View {
        SoftStudioIconButtonBody(configuration: configuration, isActive: isActive)
    }
}

private struct SoftStudioIconButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let isActive: Bool

    var body: some View {
        configuration.label
            .font(.system(.caption, design: .rounded, weight: .semibold))
            .foregroundStyle(isActive ? SoftStudioTheme.accent : SoftStudioTheme.textPrimary)
            .padding(7)
            .background(
                Circle()
                    .fill(
                        isActive
                            ? SoftStudioTheme.accent.opacity(configuration.isPressed ? 0.26 : 0.18)
                            : Color.white.opacity(configuration.isPressed ? 0.24 : 0.12)
                    )
            )
            .overlay(
                Circle()
                    .strokeBorder(
                        isActive ? SoftStudioTheme.accent.opacity(0.26) : SoftStudioTheme.accentMuted.opacity(0.20),
                        lineWidth: 1
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .shadow(color: isActive ? SoftStudioTheme.accent.opacity(0.16) : .clear, radius: 6, y: 1)
    }
}

private struct SoftStudioToggleButtonStyle: ButtonStyle {
    let isActive: Bool

    func makeBody(configuration: Configuration) -> some View {
        SoftStudioToggleButtonBody(configuration: configuration, isActive: isActive)
    }
}

private struct SoftStudioToggleButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let isActive: Bool

    var body: some View {
        configuration.label
            .foregroundStyle(isActive ? SoftStudioTheme.accent : SoftStudioTheme.textPrimary)
            .background(
                Capsule(style: .continuous)
                    .fill(isActive ? SoftStudioTheme.chipActiveFill : SoftStudioTheme.chipFill)
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(
                        isActive ? SoftStudioTheme.accent.opacity(0.28) : SoftStudioTheme.accentMuted.opacity(0.18),
                        lineWidth: 1
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .shadow(color: isActive ? SoftStudioTheme.accent.opacity(0.12) : .clear, radius: 8, y: 2)
    }
}
