import CoreGraphics
import XCTest

final class SettingsStoreTests: XCTestCase {
    private var suiteName: String!
    private var userDefaults: UserDefaults!
    private var settingsStore: SettingsStore!

    override func setUp() {
        super.setUp()

        suiteName = "SettingsStoreTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
        userDefaults.removePersistentDomain(forName: suiteName)
        settingsStore = SettingsStore(userDefaults: userDefaults)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        settingsStore = nil
        userDefaults = nil
        suiteName = nil

        super.tearDown()
    }

    func testLoadReturnsDefaultsWhenNothingHasBeenSaved() {
        let settings = settingsStore.load()

        XCTAssertEqual(settings.notesText, "")
        XCTAssertEqual(settings.windowOpacity, OverlaySettings.defaultOpacity, accuracy: 0.0001)
        XCTAssertEqual(settings.fontSize, OverlaySettings.defaultFontSize, accuracy: 0.0001)
        XCTAssertEqual(settings.windowFrame, OverlaySettings.defaultWindowFrame)
        XCTAssertFalse(settings.isClickThroughEnabled)
    }

    func testLoadReturnsPreviouslySavedValues() {
        let expectedFrame = CGRect(x: 120, y: 160, width: 560, height: 410)

        settingsStore.saveNotes("Presenter notes")
        settingsStore.saveOpacity(0.65)
        settingsStore.saveFontSize(20)
        settingsStore.saveWindowFrame(expectedFrame)
        settingsStore.saveClickThroughEnabled(true)

        let settings = settingsStore.load()

        XCTAssertEqual(settings.notesText, "Presenter notes")
        XCTAssertEqual(settings.windowOpacity, 0.65, accuracy: 0.0001)
        XCTAssertEqual(settings.fontSize, 20, accuracy: 0.0001)
        XCTAssertEqual(settings.windowFrame, expectedFrame)
        XCTAssertTrue(settings.isClickThroughEnabled)
    }

    func testSaveOpacityClampsToSupportedRange() {
        settingsStore.saveOpacity(3.0)
        XCTAssertEqual(settingsStore.load().windowOpacity, 1.0, accuracy: 0.0001)

        settingsStore.saveOpacity(0.05)
        XCTAssertEqual(settingsStore.load().windowOpacity, 0.2, accuracy: 0.0001)
    }

    func testSaveFontSizeClampsToSupportedRange() {
        settingsStore.saveFontSize(100)
        XCTAssertEqual(settingsStore.load().fontSize, 28, accuracy: 0.0001)

        settingsStore.saveFontSize(2)
        XCTAssertEqual(settingsStore.load().fontSize, 12, accuracy: 0.0001)
    }

    func testLoadFallsBackToDefaultFrameWhenStoredFrameIsInvalid() {
        userDefaults.set("{{0, 0}, {0, 0}}", forKey: "windowFrame")

        let settings = settingsStore.load()

        XCTAssertEqual(settings.windowFrame, OverlaySettings.defaultWindowFrame)
    }
}
