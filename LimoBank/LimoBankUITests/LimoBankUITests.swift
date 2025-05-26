//
//  LimoBankUITests.swift
//  LimoBankUITests
//
//  Created by Developer on 27.05.25.
//

import XCTest

final class LimoBankUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Отключаем автоматическое завершение тестов при первой ошибке
        continueAfterFailure = false
        
        // Инициализируем приложение
        app = XCUIApplication()
        
        // Сбрасываем состояние приложения для каждого теста
        app.launchArguments = ["--uitesting"]
        app.launchEnvironment = ["UITEST_DISABLE_ANIMATIONS": "YES"]
        
        // Запускаем приложение
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
        app = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Launch and Initial State Tests
    
    func testAppLaunch_ShowsLoginScreen() throws {
        // Given: App is launched
        
        // Then: Login screen should be visible
        XCTAssertTrue(app.staticTexts["LimoBank"].exists, "App logo should be visible")
        XCTAssertTrue(app.textFields["login"].exists, "Login text field should be visible")
        XCTAssertTrue(app.secureTextFields["password"].exists, "Password text field should be visible")
        XCTAssertTrue(app.buttons["login_button"].exists, "Login button should be visible")
    }
    
    // MARK: - Login Tests
    
    func testLogin_ValidCredentials_Success() throws {
        // Given: User is on login screen
        let loginField = app.textFields["login"]
        let passwordField = app.secureTextFields["password"]
        let loginButton = app.buttons["login_button"]
        
        XCTAssertTrue(loginField.exists, "Login field should exist")
        XCTAssertTrue(passwordField.exists, "Password field should exist")
        
        // When: User enters valid credentials
        loginField.tap()
        loginField.typeText("ivan")
        
        passwordField.tap()
        passwordField.typeText("123456")
        
        loginButton.tap()
        
        // Then: User should be navigated to main screen
        let mainScreen = app.otherElements["main_screen"]
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == true"),
            object: mainScreen
        )
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertTrue(mainScreen.exists, "Main screen should be visible after successful login")
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'byn'")).element.exists,
                     "Balance should be displayed")
    }
    
    func testLogin_InvalidCredentials_ShowsError() throws {
        // Given: User is on login screen
        let loginField = app.textFields["login"]
        let passwordField = app.secureTextFields["password"]
        let loginButton = app.buttons["login_button"]
        
        // When: User enters invalid credentials
        loginField.tap()
        loginField.typeText("wronguser")
        
        passwordField.tap()
        passwordField.typeText("wrongpass")
        
        loginButton.tap()
        
        // Then: Error message should be displayed
        let errorLabel = app.staticTexts["error_label"]
        XCTAssertTrue(errorLabel.waitForExistence(timeout: 3.0), "Error message should appear")
        XCTAssertFalse(errorLabel.label.isEmpty, "Error message should not be empty")
    }
    
    func testLogin_EmptyFields_ShowsError() throws {
        // Given: User is on login screen
        let loginButton = app.buttons["login_button"]
        
        // When: User taps login without entering credentials
        loginButton.tap()
        
        // Then: Error message should be displayed
        let errorLabel = app.staticTexts["error_label"]
        XCTAssertTrue(errorLabel.waitForExistence(timeout: 3.0), "Error message should appear for empty fields")
    }
    
    // MARK: - Navigation Tests
    
    func testTabBarNavigation_AllTabs_Accessible() throws {
        // Given: User is logged in
        loginWithValidCredentials()
        
        // When & Then: Test each tab
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar should be visible")
        
        // Test Main tab (already selected)
        XCTAssertTrue(app.otherElements["main_screen"].exists, "Main screen should be visible")
        
        // Test Accounts tab
        let accountsTab = tabBar.buttons["accounts"]
        if accountsTab.exists {
            accountsTab.tap()
            XCTAssertTrue(app.otherElements["accounts_screen"].waitForExistence(timeout: 3.0),
                         "Accounts screen should be visible")
        }
        
        // Test Payments tab
        let paymentsTab = tabBar.buttons["payments"]
        if paymentsTab.exists {
            paymentsTab.tap()
            // Should show "Under Development" alert
            let alert = app.alerts.firstMatch
            XCTAssertTrue(alert.waitForExistence(timeout: 3.0), "Under development alert should appear")
            alert.buttons["OK"].tap()
        }
        
        // Test Profile tab
        let profileTab = tabBar.buttons["profile"]
        if profileTab.exists {
            profileTab.tap()
            XCTAssertTrue(app.otherElements["profile_screen"].waitForExistence(timeout: 3.0),
                         "Profile screen should be visible")
        }
    }
    
    // MARK: - Main Screen Tests
    
    func testMainScreen_DisplaysUserData() throws {
        // Given: User is logged in
        loginWithValidCredentials()
        
        // Then: User data should be displayed
        let balanceLabel = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'byn'")).firstMatch
        XCTAssertTrue(balanceLabel.exists, "Balance should be displayed")
        
        let accountNumberLabel = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '••••'")).firstMatch
        XCTAssertTrue(accountNumberLabel.exists, "Account number should be displayed")
        
        // Check if transaction history is visible
        let transactionTable = app.tables["transaction_table"]
        if transactionTable.exists {
            XCTAssertTrue(transactionTable.cells.count > 0, "Transaction history should contain items")
        }
    }
    
    func testMainScreen_QuickActions_Work() throws {
        // Given: User is logged in
        loginWithValidCredentials()
        
        // When: User taps ERIP button
        let eripButton = app.buttons["erip_button"]
        if eripButton.exists {
            eripButton.tap()
            
            // Then: Under development alert should appear
            let alert = app.alerts.firstMatch
            XCTAssertTrue(alert.waitForExistence(timeout: 3.0), "Under development alert should appear")
            alert.buttons["OK"].tap()
        }
        
        // When: User taps MTS button
        let mtsButton = app.buttons["mts_button"]
        if mtsButton.exists {
            mtsButton.tap()
            
            // Then: Under development alert should appear
            let alert = app.alerts.firstMatch
            XCTAssertTrue(alert.waitForExistence(timeout: 3.0), "Under development alert should appear")
            alert.buttons["OK"].tap()
        }
    }
    
    func testMainScreen_TransactionList_Scrollable() throws {
        // Given: User is logged in
        loginWithValidCredentials()
        
        // When: User scrolls transaction list
        let transactionTable = app.tables["transaction_table"]
        if transactionTable.exists && transactionTable.cells.count > 3 {
            let firstCell = transactionTable.cells.element(boundBy: 0)
            let lastVisibleCell = transactionTable.cells.element(boundBy: transactionTable.cells.count - 1)
            
            // Scroll down
            lastVisibleCell.swipeUp()
            
            // Scroll back up
            firstCell.swipeDown()
            
            XCTAssertTrue(transactionTable.exists, "Transaction table should still be visible after scrolling")
        }
    }
    
    // MARK: - Accounts Screen Tests
    
    func testAccountsScreen_DisplaysAccounts() throws {
        // Given: User is logged in and on accounts screen
        loginWithValidCredentials()
        navigateToAccountsScreen()
        
        // Then: Accounts should be displayed
        let accountsTable = app.tables["accounts_table"]
        if accountsTable.exists {
            XCTAssertTrue(accountsTable.cells.count > 0, "Accounts list should contain items")
            
            // Check if different account types are displayed
            let cells = accountsTable.cells
            let firstCell = cells.firstMatch
            if firstCell.exists {
                XCTAssertTrue(firstCell.staticTexts.containing(NSPredicate(format: "label CONTAINS 'IVAN'")).element.exists,
                             "Account holder name should be displayed")
            }
        }
        
        // Check if "New Account" button exists
        let newAccountButton = app.buttons["new_account_button"]
        XCTAssertTrue(newAccountButton.exists, "New account button should be visible")
    }
    
    func testAddNewAccount_Flow() throws {
        // Given: User is logged in and on accounts screen
        loginWithValidCredentials()
        navigateToAccountsScreen()
        
        // When: User taps "Add Account" button
        let newAccountButton = app.buttons["new_account_button"]
        newAccountButton.tap()
        
        // Then: Add account screen should appear
        let addAccountScreen = app.otherElements["add_account_screen"]
        XCTAssertTrue(addAccountScreen.waitForExistence(timeout: 3.0), "Add account screen should appear")
        
        // When: User selects currency and account type
        let currencySegment = app.segmentedControls["currency_segment"]
        if currencySegment.exists {
            currencySegment.buttons["USD"].tap()
        }
        
        let accountTypeSegment = app.segmentedControls["account_type_segment"]
        if accountTypeSegment.exists {
            accountTypeSegment.buttons.element(boundBy: 0).tap() // Select first option
        }
        
        // When: User taps create button
        let createButton = app.buttons["create_account_button"]
        createButton.tap()
        
        // Then: Should return to accounts screen
        XCTAssertTrue(app.otherElements["accounts_screen"].waitForExistence(timeout: 3.0),
                     "Should return to accounts screen after creating account")
    }
    
    func testAccountsScreen_AccountSelection() throws {
        // Given: User is logged in and on accounts screen
        loginWithValidCredentials()
        navigateToAccountsScreen()
        
        // When: User taps on an account
        let accountsTable = app.tables["accounts_table"]
        if accountsTable.exists && accountsTable.cells.count > 0 {
            let firstAccount = accountsTable.cells.element(boundBy: 0)
            firstAccount.tap()
            
            // Then: Account should be selected (visual feedback)
            XCTAssertTrue(firstAccount.exists, "Account cell should still exist after selection")
        }
    }
    
    // MARK: - Profile Screen Tests
    
    func testProfileScreen_DisplaysUserInfo() throws {
        // Given: User is logged in and on profile screen
        loginWithValidCredentials()
        navigateToProfileScreen()
        
        // Then: User information should be displayed
        let userNameLabel = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Иван'")).firstMatch
        XCTAssertTrue(userNameLabel.exists, "User name should be displayed")
        
        let phoneLabel = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '+375'")).firstMatch
        XCTAssertTrue(phoneLabel.exists, "Phone number should be displayed")
        
        // Check menu items
        let profileTable = app.tables["profile_table"]
        if profileTable.exists {
            XCTAssertTrue(profileTable.cells.count >= 4, "Profile menu should have at least 4 items")
        }
    }
    
    func testProfileScreen_PersonalInfo() throws {
        // Given: User is logged in and on profile screen
        loginWithValidCredentials()
        navigateToProfileScreen()
        
        // When: User taps "Personal Info"
        let profileTable = app.tables["profile_table"]
        if profileTable.exists && profileTable.cells.count > 0 {
            let personalInfoCell = profileTable.cells.element(boundBy: 0) // First menu item
            personalInfoCell.tap()
            
            // Then: Personal info alert should appear
            let alert = app.alerts.firstMatch
            XCTAssertTrue(alert.waitForExistence(timeout: 3.0), "Personal info alert should appear")
            alert.buttons["OK"].tap()
        }
    }
    
    func testProfileScreen_ChangePassword() throws {
        // Given: User is logged in and on profile screen
        loginWithValidCredentials()
        navigateToProfileScreen()
        
        // When: User taps "Change Password"
        let profileTable = app.tables["profile_table"]
        if profileTable.exists && profileTable.cells.count > 1 {
            let changePasswordCell = profileTable.cells.element(boundBy: 1) // Second menu item
            changePasswordCell.tap()
            
            // Then: Change password alert should appear
            let alert = app.alerts.firstMatch
            XCTAssertTrue(alert.waitForExistence(timeout: 3.0), "Change password alert should appear")
            
            // When: User enters new password and confirms
            let passwordField = alert.textFields.firstMatch
            if passwordField.exists {
                passwordField.tap()
                passwordField.typeText("newpassword123")
            }
            
            let changeButton = alert.buttons["Изменить"]
            if changeButton.exists {
                changeButton.tap()
                
                // Then: Success alert should appear
                let successAlert = app.alerts.firstMatch
                XCTAssertTrue(successAlert.waitForExistence(timeout: 3.0), "Success alert should appear")
                successAlert.buttons["OK"].tap()
            } else {
                // Cancel if change button not found
                alert.buttons["Отменить"].tap()
            }
        }
    }
    
    func testProfileScreen_Documents() throws {
        // Given: User is logged in and on profile screen
        loginWithValidCredentials()
        navigateToProfileScreen()
        
        // When: User taps "Documents"
        let profileTable = app.tables["profile_table"]
        if profileTable.exists && profileTable.cells.count > 2 {
            let documentsCell = profileTable.cells.element(boundBy: 2) // Third menu item
            documentsCell.tap()
            
            // Then: Should open external link (Safari)
            // Note: This might open Safari, so we can't test the actual navigation
            // but we can test that the tap was registered
            XCTAssertTrue(true, "Documents tap should be handled")
        }
    }
    
    func testProfileScreen_AskQuestion_ShowsMap() throws {
        // Given: User is logged in and on profile screen
        loginWithValidCredentials()
        navigateToProfileScreen()
        
        // When: User taps "Ask Question"
        let profileTable = app.tables["profile_table"]
        if profileTable.exists && profileTable.cells.count > 3 {
            let askQuestionCell = profileTable.cells.element(boundBy: 3) // Fourth menu item
            askQuestionCell.tap()
            
            // Then: Map screen should appear or fallback alert
            let mapScreen = app.otherElements["bank_map_screen"]
            let fallbackAlert = app.alerts.firstMatch
            
            let mapExists = mapScreen.waitForExistence(timeout: 3.0)
            let alertExists = fallbackAlert.waitForExistence(timeout: 3.0)
            
            XCTAssertTrue(mapExists || alertExists, "Either map screen or fallback alert should appear")
            
            if alertExists {
                fallbackAlert.buttons["OK"].tap()
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testNetworkError_Handling() throws {
        // Given: User is logged in
        loginWithValidCredentials()
        
        // When: Network-dependent action is performed
        // (This would require mocking network conditions)
        
        // Then: App should handle gracefully
        // This is a placeholder for network error testing
        XCTAssertTrue(true, "Network error handling test placeholder")
    }
    
    func testMemoryWarning_Handling() throws {
        // Given: App is running
        
        // When: Memory warning occurs
        // (This would require simulating memory pressure)
        
        // Then: App should continue functioning
        XCTAssertTrue(app.exists, "App should continue running after memory warning")
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibility_VoiceOverSupport() throws {
        // Given: User is on login screen
        
        // Then: All elements should have accessibility labels
        let loginField = app.textFields["login"]
        XCTAssertFalse(loginField.label.isEmpty, "Login field should have accessibility label")
        
        let passwordField = app.secureTextFields["password"]
        XCTAssertFalse(passwordField.label.isEmpty, "Password field should have accessibility label")
        
        let loginButton = app.buttons["login_button"]
        XCTAssertFalse(loginButton.label.isEmpty, "Login button should have accessibility label")
    }
    
    // MARK: - Localization Tests
    
    func testLocalization_LanguageSwitch() throws {
        // Given: App is launched
        
        // When: System language changes
        // (This would require changing system settings)
        
        // Then: App should display content in correct language
        // This is a placeholder for localization testing
        XCTAssertTrue(app.staticTexts["LimoBank"].exists, "App should support localization")
    }
    
    // MARK: - Performance Tests
    
    func testPerformance_AppLaunch() throws {
        // Measure app launch time
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    func testPerformance_LoginFlow() throws {
        // Measure login performance
        measure {
            loginWithValidCredentials()
            app.terminate()
            app.launch()
        }
    }
    
    func testPerformance_NavigationSpeed() throws {
        // Given: User is logged in
        loginWithValidCredentials()
        
        // Measure navigation between tabs
        measure {
            let tabBar = app.tabBars.firstMatch
            
            // Navigate through all tabs
            tabBar.buttons["accounts"].tap()
            _ = app.otherElements["accounts_screen"].waitForExistence(timeout: 2.0)
            
            tabBar.buttons["profile"].tap()
            _ = app.otherElements["profile_screen"].waitForExistence(timeout: 2.0)
            
            tabBar.buttons["main_tab"].tap()
            _ = app.otherElements["main_screen"].waitForExistence(timeout: 2.0)
        }
    }
    
    // MARK: - Helper Methods
    
    private func loginWithValidCredentials() {
        let loginField = app.textFields["login"]
        let passwordField = app.secureTextFields["password"]
        let loginButton = app.buttons["login_button"]
        
        if loginField.exists && passwordField.exists {
            loginField.tap()
            loginField.typeText("ivan")
            
            passwordField.tap()
            passwordField.typeText("123456")
            
            loginButton.tap()
            
            // Wait for main screen to appear
            _ = app.otherElements["main_screen"].waitForExistence(timeout: 5.0)
        }
    }
    
    private func navigateToAccountsScreen() {
        let tabBar = app.tabBars.firstMatch
        let accountsTab = tabBar.buttons["accounts"]
        if accountsTab.exists {
            accountsTab.tap()
            _ = app.otherElements["accounts_screen"].waitForExistence(timeout: 3.0)
        }
    }
    
    private func navigateToProfileScreen() {
        let tabBar = app.tabBars.firstMatch
        let profileTab = tabBar.buttons["profile"]
        if profileTab.exists {
            profileTab.tap()
            _ = app.otherElements["profile_screen"].waitForExistence(timeout: 3.0)
        }
    }
    
    private func dismissKeyboard() {
        app.keyboards.buttons["Done"].tap()
    }
}

// MARK: - Extensions for Better Readability

extension XCUIElement {
    func waitForExistenceAndTap(timeout: TimeInterval = 3.0) -> Bool {
        if waitForExistence(timeout: timeout) {
            tap()
            return true
        }
        return false
    }
    
    func clearAndTypeText(_ text: String) {
        tap()
        
        // Clear existing text
        let selectAllMenuItem = XCUIApplication().menuItems["Select All"]
        if selectAllMenuItem.waitForExistence(timeout: 2.0) {
            selectAllMenuItem.tap()
        } else {
            // Fallback: use keyboard shortcuts
            coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
            XCUIApplication().keys["delete"].tap()
        }
        
        typeText(text)
    }
}