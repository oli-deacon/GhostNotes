import AppKit
import SwiftUI

@MainActor
final class OverlayWindowController: NSWindowController, NSWindowDelegate {
    private enum CameraSnapLayout {
        static let topMargin: CGFloat = 8
    }

    private let settingsStore: SettingsStore
    private let viewModel: NotesViewModel

    init(settingsStore: SettingsStore) {
        self.settingsStore = settingsStore

        let settings = settingsStore.load()
        self.viewModel = NotesViewModel(settings: settings, settingsStore: settingsStore)
        let launchOpacity = OverlaySettings.launchOpacity
        let initialFrame = Self.resolvedFrame(for: settings.windowFrame)

        let notesView = NotesView(viewModel: viewModel)
        let hostingView = NSHostingView(rootView: notesView)
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor

        let window = NSWindow(
            contentRect: initialFrame,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.title = "Ghost Notes"
        window.level = .floating
        window.isOpaque = false
        window.hasShadow = true
        window.backgroundColor = .clear
        window.alphaValue = launchOpacity
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.titlebarSeparatorStyle = .none
        window.toolbarStyle = .unifiedCompact
        window.isMovableByWindowBackground = false
        window.collectionBehavior = Self.collectionBehavior(showsOnAllSpaces: settings.showsOnAllSpaces)
        window.minSize = NSSize(width: 420, height: 220)
        window.sharingType = settings.isScreenShareExclusionEnabled ? .none : .readOnly
        window.setFrame(initialFrame, display: true)
        window.contentView = hostingView

        super.init(window: window)

        window.delegate = self
        settingsStore.saveWindowFrame(initialFrame)
        viewModel.onOpacityChanged = { [weak self] opacity in
            self?.applyOpacity(opacity)
        }
        viewModel.onClickThroughChanged = { [weak self] isEnabled in
            self?.applyClickThrough(isEnabled)
        }
        viewModel.onScreenShareExclusionChanged = { [weak self] isEnabled in
            self?.applyScreenShareExclusion(isEnabled)
        }
        viewModel.onShowsOnAllSpacesChanged = { [weak self] showsOnAllSpaces in
            self?.applyShowsOnAllSpaces(showsOnAllSpaces)
        }
        viewModel.windowOpacity = launchOpacity
        applyOpacity(launchOpacity)
        applyClickThrough(settings.isClickThroughEnabled)
        applyScreenShareExclusion(settings.isScreenShareExclusionEnabled)
        applyShowsOnAllSpaces(settings.showsOnAllSpaces)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showOverlay() {
        guard let window else { return }

        showWindow(nil)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func toggleVisibility() {
        guard let window else { return }

        if window.isVisible {
            window.orderOut(nil)
        } else {
            showOverlay()
        }
    }

    func toggleClickThrough() {
        viewModel.toggleClickThrough()
    }

    func increaseFontSize() {
        viewModel.increaseFontSize()
    }

    func decreaseFontSize() {
        viewModel.decreaseFontSize()
    }

    func increaseOpacity() {
        viewModel.increaseOpacity()
    }

    func decreaseOpacity() {
        viewModel.decreaseOpacity()
    }

    func toggleAutoScroll() {
        viewModel.toggleAutoScroll()
    }

    func snapToCameraPosition() {
        guard let window else { return }

        let targetScreen = Self.screenForSnapping(window: window)
        let visibleFrame = targetScreen.visibleFrame
        let width = min(max(window.frame.width, window.minSize.width), visibleFrame.width)
        let height = min(max(window.frame.height, window.minSize.height), visibleFrame.height)
        let originX = visibleFrame.midX - (width / 2)
        let originY = visibleFrame.maxY - height - CameraSnapLayout.topMargin
        let snappedFrame = CGRect(x: originX, y: originY, width: width, height: height)

        window.setFrame(snappedFrame, display: true, animate: true)
        persistWindowFrame()
        showOverlay()
    }

    func applyOpacity(_ opacity: Double) {
        window?.alphaValue = min(max(opacity, 0.2), 1.0)
    }

    func applyClickThrough(_ isEnabled: Bool) {
        window?.ignoresMouseEvents = isEnabled
    }

    func toggleScreenShareExclusion() {
        viewModel.toggleScreenShareExclusion()
    }

    func toggleShowsOnAllSpaces() {
        viewModel.toggleShowsOnAllSpaces()
    }

    func applyScreenShareExclusion(_ isEnabled: Bool) {
        window?.sharingType = isEnabled ? .none : .readOnly
    }

    func applyShowsOnAllSpaces(_ showsOnAllSpaces: Bool) {
        window?.collectionBehavior = Self.collectionBehavior(showsOnAllSpaces: showsOnAllSpaces)
    }

    func windowDidMove(_ notification: Notification) {
        persistWindowFrame()
    }

    func windowDidEndLiveResize(_ notification: Notification) {
        viewModel.setLiveResizing(false)
        persistWindowFrame()
    }

    func windowDidResize(_ notification: Notification) {
        persistWindowFrame()
    }

    func windowWillStartLiveResize(_ notification: Notification) {
        viewModel.setLiveResizing(true)
    }

    func windowWillClose(_ notification: Notification) {
        persistWindowFrame()
        NSApp.terminate(nil)
    }

    private func persistWindowFrame() {
        guard let frame = window?.frame else { return }
        settingsStore.saveWindowFrame(frame)
    }

    private static func resolvedFrame(for proposedFrame: CGRect) -> CGRect {
        guard let screen = NSScreen.screens.first(where: { $0.visibleFrame.intersects(proposedFrame) }) ?? NSScreen.main else {
            return proposedFrame
        }

        let visibleFrame = screen.visibleFrame
        let width = min(max(proposedFrame.width, 420), visibleFrame.width)
        let height = min(max(proposedFrame.height, 220), visibleFrame.height)

        let maxX = visibleFrame.maxX - width
        let maxY = visibleFrame.maxY - height
        let x = min(max(proposedFrame.minX, visibleFrame.minX), maxX)
        let y = min(max(proposedFrame.minY, visibleFrame.minY), maxY)

        return CGRect(x: x, y: y, width: width, height: height)
    }

    private static func screenForSnapping(window: NSWindow) -> NSScreen {
        if let containingScreen = window.screen {
            return containingScreen
        }

        let windowFrame = window.frame
        let bestScreen = NSScreen.screens.max { lhs, rhs in
            intersectionArea(of: lhs.visibleFrame, with: windowFrame) < intersectionArea(of: rhs.visibleFrame, with: windowFrame)
        }

        return bestScreen ?? NSScreen.main ?? NSScreen.screens[0]
    }

    private static func intersectionArea(of lhs: CGRect, with rhs: CGRect) -> CGFloat {
        let intersection = lhs.intersection(rhs)
        guard !intersection.isNull else { return 0 }
        return intersection.width * intersection.height
    }

    private static func collectionBehavior(showsOnAllSpaces: Bool) -> NSWindow.CollectionBehavior {
        var behavior: NSWindow.CollectionBehavior = [.fullScreenAuxiliary]

        if showsOnAllSpaces {
            behavior.insert(.canJoinAllSpaces)
        }

        return behavior
    }
}
