//
//  AccountsViewController.swift
//  LimoBank
//
//  Created by Екатерина on 26.05.25.
//

import UIKit
import CoreData

class AccountsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addAccountButton: UIButton!
    
    var accounts: [Account] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadAccounts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAccounts()
    }
    
    func setupUI() {
        view.backgroundColor = UIColor(named: "background_dark")
        navigationController?.navigationBar.isHidden = true
        
        addAccountButton.backgroundColor = UIColor(named: "background_dark")
        addAccountButton.setTitle(NSLocalizedString("new_account", comment: ""), for: .normal)
        addAccountButton.setTitleColor(UIColor(named: "text_white"), for: .normal)
        addAccountButton.layer.cornerRadius = 8
        addAccountButton.layer.borderWidth = 1
        addAccountButton.layer.borderColor = UIColor(named: "text_gray")?.cgColor
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    func loadAccounts() {
        guard let userId = UserDefaults.standard.object(forKey: "currentUserId") as? Int32 else { return }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %d", userId)
        request.sortDescriptors = [NSSortDescriptor(key: "accountType", ascending: true)]
        
        do {
            accounts = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Error loading accounts: \(error)")
        }
    }
    
    @IBAction func addAccountButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addAccountVC = storyboard.instantiateViewController(withIdentifier: "AddAccountViewController")
        addAccountVC.modalPresentationStyle = .pageSheet
        present(addAccountVC, animated: true)
    }
}

// MARK: - TableView DataSource & Delegate
extension AccountsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as! AccountTableViewCell
        let account = accounts[indexPath.row]
        cell.configure(with: account)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
