import AppKit
import XCTest

@MainActor
final class OverlayWindowControllerTests: XCTestCase {
    private var suiteName: String!
    private var userDefaults: UserDefaults!
    private var settingsStore: SettingsStore!
    private var controller: OverlayWindowController?

    override func setUp() {
        super.setUp()

        suiteName = "OverlayWindowControllerTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
        userDefaults.removePersistentDomain(forName: suiteName)
        settingsStore = SettingsStore(userDefaults: userDefaults)
    }

    override func tearDown() {
        controller?.window?.delegate = nil
        controller?.close()
        controller = nil

        userDefaults.removePersistentDomain(forName: suiteName)
        settingsStore = nil
        userDefaults = nil
        suiteName = nil

        super.tearDown()
    }

    func testInitialWindowSharingTypeDefaultsToNone() throws {
        controller = OverlayWindowController(settingsStore: settingsStore)
        let window = try XCTUnwrap(controller?.window)

        XCTAssertEqual(
            window.sharingType.rawValue,
            NSWindow.SharingType.none.rawValue,
            "Expected default sharingType .none, got rawValue \(window.sharingType.rawValue)"
        )
    }

    func testInitialWindowShowsOnAllSpacesByDefault() throws {
        controller = OverlayWindowController(settingsStore: settingsStore)
        let window = try XCTUnwrap(controller?.window)

        XCTAssertTrue(window.collectionBehavior.contains(.canJoinAllSpaces))
        XCTAssertTrue(window.collectionBehavior.contains(.fullScreenAuxiliary))
    }

    func testInitialWindowSharingTypeCanLoadAsReadOnly() throws {
        settingsStore.saveScreenShareExclusionEnabled(false)

        controller = OverlayWindowController(settingsStore: settingsStore)
        let window = try XCTUnwrap(controller?.window)

        XCTAssertEqual(
            window.sharingType.rawValue,
            NSWindow.SharingType.readOnly.rawValue,
            "Expected disabled sharingType .readOnly, got rawValue \(window.sharingType.rawValue)"
        )
    }

    func testToggleScreenShareExclusionPersistsAndNewWindowReflectsUpdatedSharingType() throws {
        controller = OverlayWindowController(settingsStore: settingsStore)

        controller?.toggleScreenShareExclusion()
        XCTAssertFalse(settingsStore.load().isScreenShareExclusionEnabled)

        controller?.window?.delegate = nil
        controller?.close()
        controller = OverlayWindowController(settingsStore: settingsStore)
        let window = try XCTUnwrap(controller?.window)

        XCTAssertEqual(
            window.sharingType.rawValue,
            NSWindow.SharingType.readOnly.rawValue,
            "Expected recreated disabled sharingType .readOnly, got rawValue \(window.sharingType.rawValue)"
        )

        controller?.toggleScreenShareExclusion()
        XCTAssertTrue(settingsStore.load().isScreenShareExclusionEnabled)
        XCTAssertEqual(
            window.sharingType.rawValue,
            NSWindow.SharingType.none.rawValue,
            "Expected toggled-on sharingType .none, got rawValue \(window.sharingType.rawValue)"
        )
    }

    func testSingleDisplayModePersistsAndUpdatesCollectionBehavior() throws {
        controller = OverlayWindowController(settingsStore: settingsStore)
        let initialWindow = try XCTUnwrap(controller?.window)

        XCTAssertTrue(initialWindow.collectionBehavior.contains(.canJoinAllSpaces))

        controller?.toggleShowsOnAllSpaces()
        XCTAssertFalse(settingsStore.load().showsOnAllSpaces)
        XCTAssertFalse(initialWindow.collectionBehavior.contains(.canJoinAllSpaces))
        XCTAssertTrue(initialWindow.collectionBehavior.contains(.fullScreenAuxiliary))

        controller?.window?.delegate = nil
        controller?.close()
        controller = OverlayWindowController(settingsStore: settingsStore)
        let recreatedWindow = try XCTUnwrap(controller?.window)

        XCTAssertFalse(recreatedWindow.collectionBehavior.contains(.canJoinAllSpaces))
        XCTAssertTrue(recreatedWindow.collectionBehavior.contains(.fullScreenAuxiliary))
    }
}
