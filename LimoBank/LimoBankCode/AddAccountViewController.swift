//
//  AddAccountViewController.swift
//  LimoBank
//
//  Created by Zharnasek Daniil on 26.05.25.
//

import UIKit
import CoreData

class AddAccountViewController: UIViewController {
    @IBOutlet weak var currencySegmentedControl: UISegmentedControl!
    @IBOutlet weak var accountTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = UIColor(named: "background_dark")
        
        currencySegmentedControl.setTitle("BYN", forSegmentAt: 0)
        currencySegmentedControl.setTitle("USD", forSegmentAt: 1)
        currencySegmentedControl.setTitle("EUR", forSegmentAt: 2)
        
        accountTypeSegmentedControl.setTitle("Обычный", forSegmentAt: 0)
        accountTypeSegmentedControl.setTitle("Кредитный", forSegmentAt: 1)
        
        createButton.backgroundColor = UIColor(named: "primary_yellow")
        createButton.setTitleColor(.black, for: .normal)
        createButton.layer.cornerRadius = 8
    }
    
    @IBAction func createButtonTapped(_ sender: UIButton) {
        createNewAccount()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func createNewAccount() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let account = Account(context: context)
        account.id = Int32(Date().timeIntervalSince1970)
        account.accountNumber = generateAccountNumber()
        account.balance = 0.0
        
        switch currencySegmentedControl.selectedSegmentIndex {
        case 0: account.currency = "BYN"
        case 1: account.currency = "USD"
        case 2: account.currency = "EUR"
        default: account.currency = "BYN"
        }
        
        account.accountType = accountTypeSegmentedControl.selectedSegmentIndex == 0 ? "main" : "credit"
        account.isActive = true
        account.userId = UserDefaults.standard.object(forKey: "currentUserId") as? Int32 ?? 1
        
        do {
            try context.save()
            dismiss(animated: true)
        } catch {
            print("Error creating account: \(error)")
        }
    }
    
    func generateAccountNumber() -> String {
        return String(Int.random(in: 1000...9999)) + String(Int.random(in: 1000...9999)) + String(Int.random(in: 1000...9999))
    }
}

