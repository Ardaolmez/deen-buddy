//
//  Deen_Buddy_AdvancedUITests.swift
//  Deen Buddy AdvancedUITests
//
//  Created by Arda Olmez on 2025-10-07.
//

import XCTest

final class Deen_Buddy_AdvancedUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    // MARK: - Screenshot Tests

    @MainActor
    func testGenerateScreenshots() throws {
        let app = XCUIApplication()
        app.launch()

        // Wait for app to fully load
        sleep(3)

        // Screenshot 1: Today's Journey (default view)
        takeScreenshot(name: "01-TodaysJourney")

        // Screenshot 2: Quran View
        let tabBar = app.tabBars
        let quranTab = tabBar.buttons.element(boundBy: 1)
        if quranTab.exists {
            quranTab.tap()
            sleep(2)
            takeScreenshot(name: "02-QuranReading")
        }

        // Screenshot 3: Prayers View
        let prayersTab = tabBar.buttons.element(boundBy: 2)
        if prayersTab.exists {
            prayersTab.tap()
            sleep(2)
            takeScreenshot(name: "03-PrayerTimes")
        }

        // Screenshot 4: Daily Quiz
        // Go back to Today view
        let todayTab = tabBar.buttons.element(boundBy: 0)
        if todayTab.exists {
            todayTab.tap()
            sleep(2)

            // Try to find and tap the Daily Quiz button
            let quizButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'quiz'")).firstMatch
            if quizButton.exists {
                quizButton.tap()
                sleep(3)
                takeScreenshot(name: "04-DailyQuiz")

                // Close quiz (if close button exists)
                let closeButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'close' OR label CONTAINS[c] 'done'")).firstMatch
                if closeButton.exists {
                    closeButton.tap()
                    sleep(1)
                }
            }
        }

        // Screenshot 5: Explore View
        let exploreTab = tabBar.buttons.element(boundBy: 3)
        if exploreTab.exists {
            exploreTab.tap()
            sleep(2)
            takeScreenshot(name: "05-Explore")
        }
    }

    // Helper function to take and save screenshots
    @MainActor
    private func takeScreenshot(name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        // Also save to fastlane/screenshots directory
        let projectDir = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let screenshotsDir = projectDir.appendingPathComponent("fastlane/screenshots/en-US")

        do {
            try FileManager.default.createDirectory(at: screenshotsDir, withIntermediateDirectories: true)
            let imagePath = screenshotsDir.appendingPathComponent("\(name).png")
            try screenshot.pngRepresentation.write(to: imagePath)
            print("✅ Saved screenshot: \(imagePath.path)")
        } catch {
            print("❌ Failed to save screenshot \(name): \(error)")
        }
    }
}
