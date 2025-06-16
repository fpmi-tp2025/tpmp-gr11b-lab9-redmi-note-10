//
//  ProfileViewController.swift
//  LimoBank
//
//  Created by Daniil Zharnasek on 26.05.25.
//

import UIKit
import CoreData
import MapKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var currentUser: User?
    let menuItems = [
        ("personal_info", "person.circle"),
        ("change_password", "lock"),
        ("documents", "doc.text"),
        ("ask_question", "questionmark.circle")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
        setupTableView()
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
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", userId)
        
        do {
            if let user = try context.fetch(request).first {
                currentUser = user
                userNameLabel.text = "\(user.firstName) \(user.lastName)"
                phoneLabel.text = user.phone
            }
        } catch {
            print("Error loading user: \(error)")
        }
    }
}

// MARK: - TableView DataSource & Delegate
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuTableViewCell
        let item = menuItems[indexPath.row]
        cell.configure(title: NSLocalizedString(item.0, comment: ""), icon: item.1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0: // Personal Info
            showPersonalInfo()
        case 1: // Change Password
            showChangePassword()
        case 2: // Documents
            openGitHub()
        case 3: // Ask Question
            showBankLocations()
        default:
            break
        }
    }
    
    func showPersonalInfo() {
        guard let user = currentUser else { return }
        
        let alert = UIAlertController(title: NSLocalizedString("personal_info", comment: ""),
                                    message: "\(user.firstName) \(user.lastName)\n\(user.phone)",
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showChangePassword() {
        let alert = UIAlertController(title: NSLocalizedString("change_password", comment: ""),
                                    message: nil,
                                    preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Новый пароль"
            textField.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        alert.addAction(UIAlertAction(title: "Изменить", style: .default) { _ in
            // Логика изменения пароля
            self.showAlert(title: "Успешно", message: "Пароль изменен")
        })
        
        present(alert, animated: true)
    }
    
    func openGitHub() {
        if let url = URL(string: "https://github.com") {
                        UIApplication.shared.open(url)
                    }
                }
                
                func showBankLocations() {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let mapVC = storyboard.instantiateViewController(withIdentifier: "BankMapViewController")
                    present(mapVC, animated: true)
                }
                
                func showAlert(title: String, message: String) {
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    present(alert, animated: true)
                }
            }
