import XCTest
import CoreData
@testable import LimoBank

class LimoBankTests: XCTestCase {

    var coreDataStack: NSPersistentContainer!
    var context: NSManagedObjectContext!
    var loginVC: LoginViewController!
    var mainVC: MainViewController!
    var accountsVC: AccountsViewController!
    var defaults: UserDefaults!

    let kCurrentUserIdKey = "currentUserId"

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Настройка in-memory Core Data stack для тестов
        coreDataStack = NSPersistentContainer(name: "LimoBank")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        coreDataStack.persistentStoreDescriptions = [description]
        
        coreDataStack.loadPersistentStores { _, error in
            XCTAssertNil(error, "Core Data stack не должен содержать ошибок при загрузке.")
        }
        
        context = coreDataStack.viewContext

        // Настройка View Controllers
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        XCTAssertNotNil(loginVC, "LoginViewController не должен быть nil после инициализации из Storyboard.")
        loginVC.loadViewIfNeeded()

        mainVC = storyboard.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController
        XCTAssertNotNil(mainVC, "MainViewController не должен быть nil после инициализации из Storyboard.")
        mainVC.loadViewIfNeeded()

        accountsVC = storyboard.instantiateViewController(withIdentifier: "AccountsViewController") as? AccountsViewController
        XCTAssertNotNil(accountsVC, "AccountsViewController не должен быть nil после инициализации из Storyboard.")
        accountsVC.loadViewIfNeeded()

        defaults = UserDefaults.standard
        defaults.removeObject(forKey: kCurrentUserIdKey)
    }

    override func tearDownWithError() throws {
        // Очистка тестовых данных
        clearCoreData()
        
        coreDataStack = nil
        context = nil
        loginVC = nil
        mainVC = nil
        accountsVC = nil
        
        defaults.removeObject(forKey: kCurrentUserIdKey)
        defaults = nil
        
        try super.tearDownWithError()
    }
	

    // MARK: - Helper Methods
    
    private func clearCoreData() {
        let entities = ["User", "Account", "Transaction"]
        
        for entityName in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                print("Ошибка очистки данных для \(entityName): \(error)")
            }
        }
    }
    
    private func createTestUser(login: String = "testuser", password: String = "password123") -> User {
        let user = User(context: context)
        user.id = Int32.random(in: 1...10000)
        user.login = login
        user.password = password
        user.firstName = "Тест"
        user.lastName = "Пользователь"
        user.phone = "+375291234567"
        
        do {
            try context.save()
        } catch {
            XCTFail("Ошибка создания тестового пользователя: \(error)")
        }
        
        return user
    }
    
    private func createTestAccount(for user: User, type: String = "main", currency: String = "BYN", balance: Double = 1000.0) -> Account {
        let account = Account(context: context)
        account.id = Int32.random(in: 1...10000)
        account.accountNumber = "1234567890123456"
        account.balance = balance
        account.currency = currency
        account.accountType = type
        account.isActive = true
        account.userId = user.id
        account.firstName = user.firstName
        account.lastName = user.lastName
        
        do {
            try context.save()
        } catch {
            XCTFail("Ошибка создания тестового счета: \(error)")
        }
        
        return account
    }

    // MARK: - Core Data Model Tests

    func testCreateUser_ValidData_Success() {
        // Given
        let login = "newuser"
        let password = "securepassword"
        let firstName = "Иван"
        let lastName = "Иванов"
        let phone = "+375291111111"

        // When
        let user = User(context: context)
        user.id = 1
        user.login = login
        user.password = password
        user.firstName = firstName
        user.lastName = lastName
        user.phone = phone

        do {
            try context.save()
        } catch {
            XCTFail("Ошибка сохранения пользователя: \(error)")
        }

        // Then
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "login == %@", login)

        do {
            let users = try context.fetch(fetchRequest)
            XCTAssertEqual(users.count, 1, "Должен быть создан один пользователь.")
            
            let savedUser = users.first!
            XCTAssertEqual(savedUser.login, login)
            XCTAssertEqual(savedUser.password, password)
            XCTAssertEqual(savedUser.firstName, firstName)
            XCTAssertEqual(savedUser.lastName, lastName)
            XCTAssertEqual(savedUser.phone, phone)
        } catch {
            XCTFail("Ошибка загрузки пользователя: \(error)")
        }
    }

    func testCreateAccount_ValidData_Success() {
        // Given
        let user = createTestUser()
        let accountNumber = "1111222233334444"
        let balance = 1500.50
        let currency = "USD"
        let accountType = "foreign"

        // When
        let account = Account(context: context)
        account.id = 1
        account.accountNumber = accountNumber
        account.balance = balance
        account.currency = currency
        account.accountType = accountType
        account.isActive = true
        account.userId = user.id
        account.firstName = user.firstName
        account.lastName = user.lastName

        do {
            try context.save()
        } catch {
            XCTFail("Ошибка сохранения счета: \(error)")
        }


        // Then
        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %d", user.id)

        do {
            let accounts = try context.fetch(fetchRequest)
            XCTAssertEqual(accounts.count, 1, "Должен быть создан один счет.")
            
            let savedAccount = accounts.first!
            XCTAssertEqual(savedAccount.accountNumber, accountNumber)
            XCTAssertEqual(savedAccount.balance, balance, accuracy: 0.01)
            XCTAssertEqual(savedAccount.currency, currency)
            XCTAssertEqual(savedAccount.accountType, accountType)
            XCTAssertTrue(savedAccount.isActive)
        } catch {
            XCTFail("Ошибка загрузки счета: \(error)")
        }
    }

    func testCreateTransaction_ValidData_Success() {
        // Given
        let user = createTestUser()
        let account = createTestAccount(for: user)
        let description = "Тестовый платеж"
        let amount = -50.0
        let category = "transport"
        let type = "expense"

        // When
        let transaction = Transaction(context: context)
        transaction.id = 1
        transaction.transactionDescription = description
        transaction.amount = amount
        transaction.category = category
        transaction.type = type
        transaction.accountId = account.id
        transaction.transactionDate = Date()

        do {
            try context.save()
        } catch {
            XCTFail("Ошибка сохранения транзакции: \(error)")
        }

        // Then
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "accountId == %d", account.id)

        do {
            let transactions = try context.fetch(fetchRequest)
            XCTAssertEqual(transactions.count, 1, "Должна быть создана одна транзакция.")
            
            let savedTransaction = transactions.first!
            XCTAssertEqual(savedTransaction.transactionDescription, description)
            XCTAssertEqual(savedTransaction.amount, amount, accuracy: 0.01)
            XCTAssertEqual(savedTransaction.category, category)
            XCTAssertEqual(savedTransaction.type, type)
            XCTAssertNotNil(savedTransaction.transactionDate)
        } catch {
            XCTFail("Ошибка загрузки транзакции: \(error)")
        }
    }

    // MARK: - LoginViewController Tests

    func testAuthentication_ValidCredentials_Success() {
        // Given
        let user = createTestUser(login: "validuser", password: "validpass")
        loginVC.loginTextField.text = "validuser"
        loginVC.passwordTextField.text = "validpass"

        // When
        let isAuthenticated = loginVC.authenticateUser(login: "validuser", password: "validpass")

        // Then
        XCTAssertTrue(isAuthenticated, "Аутентификация должна быть успешной с правильными данными.")
        XCTAssertEqual(defaults.object(forKey: kCurrentUserIdKey) as? Int32, user.id, "ID пользователя должен быть сохранен в UserDefaults.")
    }

    func testAuthentication_InvalidCredentials_Failure() {
        // Given
        _ = createTestUser(login: "validuser", password: "validpass")
        loginVC.loginTextField.text = "validuser"
        loginVC.passwordTextField.text = "wrongpass"

        // When
        let isAuthenticated = loginVC.authenticateUser(login: "validuser", password: "wrongpass")

        // Then
        XCTAssertFalse(isAuthenticated, "Аутентификация должна провалиться с неправильным паролем.")
        XCTAssertNil(defaults.object(forKey: kCurrentUserIdKey), "ID пользователя не должен быть сохранен.")
    }

    func testAuthentication_UserNotExists_Failure() {
        // Given
        loginVC.loginTextField.text = "nonexistentuser"
        loginVC.passwordTextField.text = "anypassword"

        // When
        let isAuthenticated = loginVC.authenticateUser(login: "nonexistentuser", password: "anypassword")


        // Then
        XCTAssertFalse(isAuthenticated, "Аутентификация должна провалиться для несуществующего пользователя.")
        XCTAssertNil(defaults.object(forKey: kCurrentUserIdKey), "ID пользователя не должен быть сохранен.")
    }

    func testAuthentication_EmptyFields_Failure() {
        // Given
        loginVC.loginTextField.text = ""
        loginVC.passwordTextField.text = ""

        // When
        let isAuthenticated = loginVC.authenticateUser(login: "", password: "")

        // Then
        XCTAssertFalse(isAuthenticated, "Аутентификация должна провалиться с пустыми полями.")
        XCTAssertNil(defaults.object(forKey: kCurrentUserIdKey), "ID пользователя не должен быть сохранен.")
    }

    // MARK: - MainViewController Tests

    func testLoadUserData_ValidUser_Success() {
        // Given
        let user = createTestUser()
        let account = createTestAccount(for: user)
        defaults.set(user.id, forKey: kCurrentUserIdKey)

        // When
        mainVC.loadUserData()

        // Then
        XCTAssertNotNil(mainVC.currentUser, "Текущий пользователь должен быть загружен.")
        XCTAssertEqual(mainVC.currentUser?.id, user.id, "ID пользователя должен совпадать.")
        XCTAssertNotNil(mainVC.mainAccount, "Основной счет должен быть загружен.")
        XCTAssertEqual(mainVC.mainAccount?.id, account.id, "ID счета должен совпадать.")
    }

    func testLoadUserData_NoUser_NilData() {
        // Given
        defaults.removeObject(forKey: kCurrentUserIdKey)

        // When
        mainVC.loadUserData()

        // Then
        XCTAssertNil(mainVC.currentUser, "Текущий пользователь должен быть nil.")
        XCTAssertNil(mainVC.mainAccount, "Основной счет должен быть nil.")
    }

    func testLoadTransactions_WithAccount_Success() {
        // Given
        let user = createTestUser()
        let account = createTestAccount(for: user)
        
        // Создаем несколько транзакций
        for i in 1...3 {
            let transaction = Transaction(context: context)
            transaction.id = Int32(i)
            transaction.transactionDescription = "Транзакция \(i)"
            transaction.amount = Double(i * 10)
            transaction.category = "test"
            transaction.type = "expense"
            transaction.accountId = account.id
            transaction.transactionDate = Date()
        }
        
        do {
            try context.save()
        } catch {
            XCTFail("Ошибка сохранения транзакций: \(error)")
        }

        mainVC.mainAccount = account

        // When
        mainVC.loadTransactions()

        // Then
        XCTAssertEqual(mainVC.transactions.count, 3, "Должно быть загружено 3 транзакции.")
    }

    func testUpdateAccountDisplay_ValidAccount_Success() {
        // Given
        let user = createTestUser()
        let account = createTestAccount(for: user, currency: "USD", balance: 2500.75)
        mainVC.mainAccount = account

        // When
        mainVC.updateAccountDisplay()

        // Then
        XCTAssertEqual(mainVC.balanceLabel.text, "2500.75 USD", "Баланс должен отображаться корректно.")
        XCTAssertTrue(mainVC.accountNumberLabel.text?.contains("3456") == true, "Номер счета должен содержать последние 4 цифры.")
    }

    // MARK: - AccountsViewController Tests

    func testLoadAccounts_WithUserAccounts_Success() {
        // Given
        let user = createTestUser()
        let account1 = createTestAccount(for: user, type: "main", currency: "BYN")
        let account2 = createTestAccount(for: user, type: "credit", currency: "BYN")
        let account3 = createTestAccount(for: user, type: "foreign", currency: "USD")
        
        defaults.set(user.id, forKey: kCurrentUserIdKey)

        // When
        accountsVC.loadAccounts()


        // Then
        XCTAssertEqual(accountsVC.accounts.count, 3, "Должно быть загружено 3 счета.")
        
        let accountTypes = accountsVC.accounts.map { $0.accountType }
        XCTAssertTrue(accountTypes.contains("main"), "Должен быть основной счет.")
        XCTAssertTrue(accountTypes.contains("credit"), "Должен быть кредитный счет.")
        XCTAssertTrue(accountTypes.contains("foreign"), "Должен быть валютный счет.")
    }

    func testLoadAccounts_NoAccounts_EmptyArray() {
        // Given
        let user = createTestUser()
        defaults.set(user.id, forKey: kCurrentUserIdKey)

        // When
        accountsVC.loadAccounts()

        // Then
        XCTAssertEqual(accountsVC.accounts.count, 0, "Массив счетов должен быть пустым.")
    }

    // MARK: - Data Validation Tests

    func testUser_RequiredFields_NotNil() {
        // Given
        let user = createTestUser()

        // Then
        XCTAssertNotNil(user.login, "Login не должен быть nil.")
        XCTAssertNotNil(user.password, "Password не должен быть nil.")
        XCTAssertNotNil(user.firstName, "FirstName не должен быть nil.")
        XCTAssertNotNil(user.lastName, "LastName не должен быть nil.")
        XCTAssertNotNil(user.phone, "Phone не должен быть nil.")
    }

    func testAccount_RequiredFields_NotNil() {
        // Given
        let user = createTestUser()
        let account = createTestAccount(for: user)

        // Then
        XCTAssertNotNil(account.accountNumber, "AccountNumber не должен быть nil.")
        XCTAssertNotNil(account.currency, "Currency не должен быть nil.")
        XCTAssertNotNil(account.accountType, "AccountType не должен быть nil.")
        XCTAssertEqual(account.userId, user.id, "UserId должен совпадать с ID пользователя.")
    }

    func testTransaction_RequiredFields_NotNil() {
        // Given
        let user = createTestUser()
        let account = createTestAccount(for: user)
        
        let transaction = Transaction(context: context)
        transaction.id = 1
        transaction.transactionDescription = "Тест"
        transaction.amount = -100.0
        transaction.category = "test"
        transaction.type = "expense"
        transaction.accountId = account.id
        transaction.transactionDate = Date()

        do {
            try context.save()
        } catch {
            XCTFail("Ошибка сохранения транзакции: \(error)")
        }

        // Then
        XCTAssertNotNil(transaction.transactionDescription, "TransactionDescription не должен быть nil.")
        XCTAssertNotNil(transaction.category, "Category не должен быть nil.")
        XCTAssertNotNil(transaction.type, "Type не должен быть nil.")
        XCTAssertNotNil(transaction.transactionDate, "TransactionDate не должен быть nil.")
        XCTAssertEqual(transaction.accountId, account.id, "AccountId должен совпадать с ID счета.")
    }

    // MARK: - Performance Tests

    func testUserAuthentication_Performance() {
        // Given
        _ = createTestUser(login: "perfuser", password: "perfpass")

        // When & Then
        self.measure {
            _ = loginVC.authenticateUser(login: "perfuser", password: "perfpass")
        }
    }

    func testLoadTransactions_Performance() {
        // Given
        let user = createTestUser()
        let account = createTestAccount(for: user)
        
        // Создаем много транзакций для теста производительности
        for i in 1...100 {
            let transaction = Transaction(context: context)
            transaction.id = Int32(i)
            transaction.transactionDescription = "Транзакция \(i)"
            transaction.amount = Double(i)
            transaction.category = "test"
            transaction.type = "expense"
            transaction.accountId = account.id
            transaction.transactionDate = Date()
        }
        
        do {
            try context.save()
        } catch {
            XCTFail("Ошибка сохранения транзакций: \(error)")
        }

        mainVC.mainAccount = account


        // When & Then
        self.measure {
            mainVC.loadTransactions()
        }
    }

    func testLoadAccounts_Performance() {
        // Given
        let user = createTestUser()
        defaults.set(user.id, forKey: kCurrentUserIdKey)
        
        // Создаем много счетов для теста производительности
        for i in 1...50 {
            _ = createTestAccount(for: user, type: "test\(i)", currency: "BYN")
        }

        // When & Then
        self.measure {
            accountsVC.loadAccounts()
        }
    }
}
