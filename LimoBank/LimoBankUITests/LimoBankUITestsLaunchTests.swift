import XCTest

final class LimoBankUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Basic Launch Tests

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot
        // For example, logging into a test account or navigating to a specific screen
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    // MARK: - Launch State Tests
    
    func testLaunchWithCleanState() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--reset-user-defaults", "--clear-core-data"]
        app.launch()
        
        // Verify app launches successfully with clean state
        XCTAssertTrue(app.staticTexts["LimoBank"].waitForExistence(timeout: 10.0), 
                     "App should display logo on clean launch")
        
        // Take screenshot of clean launch
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Clean Launch State"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testLaunchWithExistingUserData() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--mock-user-data"]
        app.launch()
        
        // Verify app launches with existing user data
        XCTAssertTrue(app.staticTexts["LimoBank"].waitForExistence(timeout: 10.0), 
                     "App should display logo on launch with existing data")
        
        // Take screenshot of launch with data
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch With Existing Data"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    // MARK: - Device Configuration Tests
    
    func testLaunchOnPortraitOrientation() throws {
        let app = XCUIApplication()
        
        // Ensure portrait orientation
        XCUIDevice.shared.orientation = .portrait
        
        app.launch()
        
        XCTAssertTrue(app.staticTexts["LimoBank"].waitForExistence(timeout: 10.0), 
                     "App should launch successfully in portrait orientation")
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Portrait Launch"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testLaunchOnLandscapeOrientation() throws {
        let app = XCUIApplication()
        
        // Rotate to landscape
        XCUIDevice.shared.orientation = .landscapeLeft
        
        app.launch()
        
        XCTAssertTrue(app.staticTexts["LimoBank"].waitForExistence(timeout: 10.0), 
                     "App should launch successfully in landscape orientation")
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Landscape Launch"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // Restore portrait orientation
        XCUIDevice.shared.orientation = .portrait
    }
    
    // MARK: - Memory and Performance Tests
    
    func testLaunchWithLowMemoryWarning() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--simulate-memory-warning"]
        app.launch()
        
        // Verify app handles low memory gracefully during launch
        XCTAssertTrue(app.staticTexts["LimoBank"].waitForExistence(timeout: 15.0), 
                     "App should launch successfully even with memory warnings")
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Low Memory Launch"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testColdLaunchPerformance() throws {
        if #available(iOS 13.0, *) {
            // Test cold launch (app not in memory)
            let app = XCUIApplication()
            
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                app.launch()
                
                // Wait for app to fully load
                _ = app.staticTexts["LimoBank"].waitForExistence(timeout: 10.0)
                
                app.terminate()
            }
        }
    }
    
    func testWarmLaunchPerformance() throws {
        if #available(iOS 13.0, *) {
            // Test warm launch (app in background)
            let app = XCUIApplication()
            app.launch()
            
            // Put app in background
            XCUIDevice.shared.press(.home)
            sleep(1)
            
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                app.activate()
                
                // Wait for app to become active
                _ = app.staticTexts["LimoBank"].waitForExistence(timeout: 5.0)
            }
        }
    }
    
    // MARK: - Localization Launch Tests
    
    func testLaunchWithDifferentLocales() throws {
        let locales = ["en", "ru", "be"]
        
        for locale in locales {
            let app = XCUIApplication()
            app.launchArguments = ["--ui-testing", "--locale", locale]
            app.launch()
            
            // Verify app launches successfully with different locales
            XCTAssertTrue(app.staticTexts["LimoBank"].waitForExistence(timeout: 10.0), 
                         "App should launch successfully with \(locale) locale")
            
            let attachment = XCTAttachment(screenshot: app.screenshot())
            attachment.name = "Launch - \(locale.uppercased()) Locale"
            attachment.lifetime = .keepAlways
            add(attachment)
            
            app.terminate()
        }
    }
    
    // MARK: - Accessibility Launch Tests
    
    func testLaunchWithVoiceOverEnabled() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--enable-voiceover"]
        app.launch()
        
        // Verify app launches successfully with VoiceOver enabled
        XCTAssertTrue(app.staticTexts["LimoBank"].waitForExistence(timeout: 10.0), 
                     "App should launch successfully with VoiceOver enabled")
        
        // Verify accessibility elements exist
        let loginField = app.textFields["login"]
        XCTAssertTrue(loginField.waitForExistence(timeout: 5.0), 
                     "Login field should be accessible")
        XCTAssertFalse(loginField.label.isEmpty, 
                      "Login field should have accessibility label")
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "VoiceOver Launch"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testLaunchWithDynamicTypeEnabled() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--large-text"]
        app.launch()
        
        // Verify app launches successfully with large text
        XCTAssertTrue(app.staticTexts["LimoBank"].waitForExistence(timeout: 10.0), 
                     "App should launch successfully with dynamic type enabled")
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Dynamic Type Launch"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    // MARK: - Network Condition Launch Tests
    
    func testLaunchWithNoNetworkConnection() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--no-network"]
        app.launch()
        
        // Verify app launches successfully without network
        XCTAssertTrue(app.staticTexts["LimoBank"].waitForExistence(timeout: 10.0), 
                     "App should launch successfully without network connection")
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "No Network Launch"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testLaunchWithSlowNetworkConnection() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--slow-network"]
        app.launch()
        
        // Verify app launches successfully with slow network
        XCTAssertTrue(app.staticTexts["LimoBank"].waitForExistence(timeout: 15.0), 
                     "App should launch successfully with slow network connection")
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Slow Network Launch"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    // MARK: - Different Device Launch Tests
    
    func testLaunchOnDifferentScreenSizes() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Get current device screen size
        let screenSize = app.windows.firstMatch.frame.size
        
        // Verify app launches and displays correctly on current device
        XCTAssertTrue(app.staticTexts["LimoBank"].waitForExistence(timeout: 10.0), 
                     "App should launch on device with screen size: \(screenSize)")
        
        // Verify UI elements are properly positioned
        let loginField = app.textFields["login"]
        let passwordField = app.secureTextFields["password"]
        
        XCTAssertTrue(loginField.waitForExistence(timeout: 5.0), 
                     "Login field should be visible on this screen size")
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5.0), 
                     "Password field should be visible on this screen size")
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch - Screen Size \(Int(screenSize.width))x\(Int(screenSize.height))"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    // MARK: - Error Recovery Launch Tests
    
    func testLaunchAfterCrash() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--simulate-previous-crash"]
        app.launch()
        
        // Verify app recovers gracefully from previous crash
        XCTAssertTrue(app.staticTexts["LimoBank"].waitForExistence(timeout: 10.0), 
                     "App should launch successfully after simulated crash")
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch After Crash"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testLaunchWithCorruptedData() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--corrupted-core-data"]
        app.launch()
        
        // Verify app handles corrupted data gracefully
        XCTAssertTrue(app.staticTexts["LimoBank"].waitForExistence(timeout: 10.0), 
                     "App should launch successfully even with corrupted data")
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch With Corrupted Data"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    // MARK: - App Store Screenshot Tests
    
    func testAppStoreScreenshots() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--app-store-demo-data"]
        app.launch()
        
        // Login screen for App Store
        let loginAttachment = XCTAttachment(screenshot: app.screenshot())
        loginAttachment.name = "01 - Login Screen"
        loginAttachment.lifetime = .keepAlways
        add(loginAttachment)
        
        // Login with demo credentials
        let loginField = app.textFields["login"]
        let passwordField = app.secureTextFields["password"]
        let loginButton = app.buttons["login_button"]
        
        if loginField.exists && passwordField.exists {
            loginField.tap()
            loginField.typeText("demo")
            passwordField.tap()
            passwordField.typeText("demo")
            loginButton.tap()
        }
        
        // Wait for main screen
        _ = app.otherElements["main_screen"].waitForExistence(timeout: 5.0)
        
        let mainAttachment = XCTAttachment(screenshot: app.screenshot())
        mainAttachment.name = "02 - Main Screen"
        mainAttachment.lifetime = .keepAlways
        add(mainAttachment)
        
        // Navigate to accounts
        let tabBar = app.tabBars.firstMatch
        if tabBar.buttons["accounts"].exists {
            tabBar.buttons["accounts"].tap()
            _ = app.otherElements["accounts_screen"].waitForExistence(timeout: 3.0)
            
            let accountsAttachment = XCTAttachment(screenshot: app.screenshot())
            accountsAttachment.name = "03 - Accounts Screen"
            accountsAttachment.lifetime = .keepAlways
            add(accountsAttachment)
        }
        
        // Navigate to profile
        if tabBar.buttons["profile"].exists {
            tabBar.buttons["profile"].tap()
            _ = app.otherElements["profile_screen"].waitForExistence(timeout: 3.0)
            
            let profileAttachment = XCTAttachment(screenshot: app.screenshot())
            profileAttachment.name = "04 - Profile Screen"
            profileAttachment.lifetime = .keepAlways
            add(profileAttachment)
        }
    }
    
    // MARK: - Beta Testing Launch Tests
    
    func testBetaLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--beta-testing", "--extended-logging"]
        app.launch()
        
        // Verify beta version launches correctly
        XCTAssertTrue(app.staticTexts["LimoBank"].waitForExistence(timeout: 10.0), 
                     "Beta version should launch successfully")
        
        // Check for beta indicators or features
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Beta Launch"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    // MARK: - Advanced Launch Tests
    
    func testLaunchWithDifferentLanguageKeyboards() throws {
        let keyboards = ["en", "ru", "be"]
        
        for keyboard in keyboards {
            let app = XCUIApplication()
            app.launchArguments = ["--ui-testing", "--keyboard", keyboard]
            app.launch()
            
            // Test keyboard functionality
            let loginField = app.textFields["login"]
            if loginField.exists {
                loginField.tap()
                
                // Check if keyboard appears
                XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 3.0), 
                             "Keyboard should appear with \(keyboard) layout")
                
                // Type some text to test keyboard
                loginField.typeText("test")
                
                // Dismiss keyboard
                app.toolbars.buttons["Done"].tap()
            }
            
            let attachment = XCTAttachment(screenshot: app.screenshot())
            attachment.name = "Launch - \(keyboard.uppercased()) Keyboard"
            attachment.lifetime = .keepAlways
            add(attachment)
            
            app.terminate()
        }
    }
    
    func testLaunchWithDifferentSystemSettings() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--simulate-system-settings-changes"]
        app.launch()
        
        // Test with different system settings simulated
        XCTAssertTrue(app.staticTexts["LimoBank"].waitForExistence(timeout: 10.0), 
                     "App should adapt to system setting changes")
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch With System Settings"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testLaunchStressTest() throws {
        // Launch and terminate app multiple times quickly
        let launchCount = 5
        
        measure {
            for i in 1...launchCount {
                let app = XCUIApplication()
                app.launch()
                
                // Wait for app to load
                _ = app.staticTexts["LimoBank"].waitForExistence(timeout: 5.0)
                
                // Take screenshot for the first and last launch
                if i == 1 || i == launchCount {
                    let attachment = XCTAttachment(screenshot: app.screenshot())
                    attachment.name = "Stress Test Launch \(i)"
                    attachment.lifetime = .keepAlways
                    add(attachment)
                }
                
                app.terminate()
            }
        }
    }
}

// MARK: - Launch Test Extensions

extension LimoBankUITestsLaunchTests {
    
    /// Helper method to capture launch metrics
    private func captureLaunchMetrics(testName: String, 
                                    app: XCUIApplication,
                                    timeout: TimeInterval = 10.0) {
        let startTime = Date()
        
        // Wait for app to fully load
        _ = app.staticTexts["LimoBank"].waitForExistence(timeout: timeout)
        
        let launchTime = Date().timeIntervalSince(startTime)
        
        // Log launch time
        print("🚀 \(testName) launch time: \(String(format: "%.2f", launchTime))s")
        
        // Capture screenshot
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = testName
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    /// Helper method to verify basic app elements exist
    private func verifyBasicAppElements(app: XCUIApplication) {
        // Check for essential UI elements
        XCTAssertTrue(app.staticTexts["LimoBank"].exists, "App logo should be visible")
        XCTAssertTrue(app.textFields["login"].exists, "Login field should be visible")
        XCTAssertTrue(app.secureTextFields["password"].exists, "Password field should be visible")
        XCTAssertTrue(app.buttons["login_button"].exists, "Login button should be visible")
    }
    
    /// Helper method to check app responsiveness
    private func verifyAppResponsiveness(app: XCUIApplication) {
        // Test that UI elements respond to interaction
        let loginField = app.textFields["login"]
        loginField.tap()
        
        // Verify keyboard appears
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 3.0), 
                     "Keyboard should appear when text field is tapped")
        
        // Dismiss keyboard
        if app.toolbars.buttons["Done"].exists {
            app.toolbars.buttons["Done"].tap()
        }
    }
    
    /// Helper method for automated screenshot capture
    private func captureScreenshotWithMetadata(name: String, description: String = "") {
        let app = XCUIApplication()
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        
        if !description.isEmpty {
            // Add description as metadata
            print("📸 Screenshot: \(name) - \(description)")
        }
        
        add(attachment)
    }
}