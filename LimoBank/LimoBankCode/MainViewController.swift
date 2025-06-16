//
//  MainViewController.swift
//  LimoBank
//
//  Created by Daniil Zharnasek on 26.05.25.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var quickActionsStackView: UIStackView!
    
    var transactions: [Transaction] = []
    var currentUser: User?
    var mainAccount: Account?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
        setupTableView()
        createSampleData()
    }
    
    func setupUI() {
        view.backgroundColor = UIColor(named: "background_dark")
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    func loadUserData() {
        guard let userId = UserDefaults.standard.object(forKey: "currentUserId") as? Int32 else { return }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Загружаем пользователя
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        userRequest.predicate = NSPredicate(format: "id == %d", userId)
        
        do {
            if let user = try context.fetch(userRequest).first {
                currentUser = user
                
                // Загружаем основной счет
                let accountRequest: NSFetchRequest<Account> = Account.fetchRequest()
                accountRequest.predicate = NSPredicate(format: "userId == %d AND accountType == %@", userId, "main")
                
                if let account = try context.fetch(accountRequest).first {
                    mainAccount = account
                    updateAccountDisplay()
                }
                
                // Загружаем транзакции
                loadTransactions()
            }
        } catch {
            print("Error loading user data: \(error)")
        }
    }
    
    func updateAccountDisplay() {
        guard let account = mainAccount else { return }
        balanceLabel.text = String(format: "%.2f %@", account.balance, account.currency!)
        accountNumberLabel.text = "•••• •••• •••• \(String(account.accountNumber!.suffix(4)))"
    }
    
    func loadTransactions() {
        guard let account = mainAccount else { return }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "accountId == %d", account.id)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            transactions = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Error loading transactions: \(error)")
        }
    }
    
    func createSampleData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Проверяем, есть ли уже счета
        let accountRequest: NSFetchRequest<Account> = Account.fetchRequest()
        do {
            let accounts = try context.fetch(accountRequest)
            if accounts.isEmpty {
                // Создаем основной счет
                let mainAccount = Account(context: context)
                mainAccount.id = 1
                mainAccount.accountNumber = "6667019372461"
                mainAccount.balance = 1500.21
                mainAccount.currency = "BYN"
                mainAccount.accountType = "main"
                mainAccount.isActive = true
                mainAccount.userId = 1
                
                // Создаем кредитный счет
                let creditAccount = Account(context: context)
                creditAccount.id = 2
                creditAccount.accountNumber = "7612"
                creditAccount.balance = -107.98

                creditAccount.currency = "BYN"
                creditAccount.accountType = "credit"
                creditAccount.isActive = true
                creditAccount.userId = 1
                
                // Создаем валютный счет
                let foreignAccount = Account(context: context)
                foreignAccount.id = 3
                foreignAccount.accountNumber = "123302271234"
                foreignAccount.balance = 102.32
                foreignAccount.currency = "USD"
                foreignAccount.accountType = "foreign"
                foreignAccount.isActive = true
                foreignAccount.userId = 1
                
                // Создаем транзакции
                createSampleTransactions(context: context)
                
                try context.save()
                print("Sample data created")
            }
        } catch {
            print("Error creating sample data: \(error)")
        }
    }
    
    func createSampleTransactions(context: NSManagedObjectContext) {
        let transactionData = [
            ("TRANSPORT PAYBYCARD.BY", -1.0, "transport", "2025-05-26"),
            ("папаўленне рахунку", 50.0, "income", "2025-05-25"),
            ("cofix", -12.2, "coffee", "2025-05-24"),
            ("TRANSPORT PAYBYCARD.BY", -1.0, "transport", "2025-05-23"),
            ("папаўленне крэдыту", -4.30, "credit", "2025-05-22")
        ]
        
        for (index, (description, amount, category, dateString)) in transactionData.enumerated() {
            let transaction = Transaction(context: context)
            transaction.id = Int32(index + 1)
            transaction.transactionDiscriprion = description
            transaction.amount = amount
            transaction.category = category
            transaction.type = amount > 0 ? "income" : "expense"
            transaction.accountId = 1
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            transaction.transactionDate = formatter.date(from: dateString) ?? Date()
        }
    }
    
    @IBAction func eripButtonTapped(_ sender: UIButton) {
        // ЕРИП функциональность
        showUnderDevelopment()
    }
    
    @IBAction func mtsButtonTapped(_ sender: UIButton) {
        // МТС функциональность
        showUnderDevelopment()
    }
    
    @IBAction func accountsButtonTapped(_ sender: UIButton) {
        // Переход на экран счетов
        tabBarController?.selectedIndex = 1
    }
    
    func showUnderDevelopment() {
        let alert = UIAlertController(title: NSLocalizedString("under_development", comment: ""),
                                    message: nil,
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TableView DataSource & Delegate
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionTableViewCell
        let transaction = transactions[indexPath.row]
        cell.configure(with: transaction)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
