//
//  LoginViewController.swift
//  LimoBank
//
//  Created by Daniil Zharnasek on 26.05.25.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        createDefaultUser() // Создаем тестового пользователя
    }
    
    func setupUI() {
        view.backgroundColor = UIColor(named: "background_dark")
        errorLabel.isHidden = true
        errorLabel.textColor = .red
        
        loginTextField.placeholder = NSLocalizedString("login", comment: "")
        passwordTextField.placeholder = NSLocalizedString("password", comment: "")
        passwordTextField.isSecureTextEntry = true
        
        loginButton.backgroundColor = UIColor(named: "primary_yellow")
        loginButton.setTitleColor(.black, for: .normal)
        loginButton.layer.cornerRadius = 8
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let login = loginTextField.text, !login.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showError(NSLocalizedString("login_error", comment: ""))
            return
        }
        
        if authenticateUser(login: login, password: password) {
            navigateToMainScreen()
        } else {
            showError(NSLocalizedString("login_error", comment: ""))
        }
    }
    
    func authenticateUser(login: String, password: String) -> Bool {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "login == %@ AND password == %@", login, password)
        
        do {
            let users = try context.fetch(request)
            if let user = users.first {
                UserDefaults.standard.set(user.id, forKey: "currentUserId")
                return true
            }
        } catch {
            print("Error fetching user: \(error)")
        }
        return false
    }
    
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    func navigateToMainScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true)
    }
    
    func createDefaultUser() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Проверяем, есть ли уже пользователи
        let request: NSFetchRequest<User> = User.fetchRequest()
        do {
            let users = try context.fetch(request)
            if users.isEmpty {
                // Создаем тестового пользователя
                let user = User(context: context)
                user.id = 1
                user.login = "ivan"
                user.password = "123456"
                user.firstName = "Иван"
                user.lastName = "Иванов"
                user.phone = "+375331222333"
                
                try context.save()
                print("Default user created")
            }
        } catch {
            print("Error creating default user: \(error)")
        }
    }
}
