//
//  AccountTableViewCell.swift
//  LimoBank
//
//  Created by Zharnasek Daniil on 26.05.25.
//

import UIKit

class AccountTableViewCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var accountTypeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        containerView.layer.cornerRadius = 12
        
        balanceLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        balanceLabel.textColor = .black
        
        accountNumberLabel.font = UIFont.systemFont(ofSize: 14)
        accountNumberLabel.textColor = .black
        
        accountTypeLabel.font = UIFont.systemFont(ofSize: 12)
        accountTypeLabel.textColor = .black
        
        statusLabel.font = UIFont.systemFont(ofSize: 12)
        statusLabel.textColor = .black
    }
    
    func configure(with account: Account) {
        balanceLabel.text = "\(String(format: "%.2f", account.balance)) \(String(describing: account.currency))"
        accountNumberLabel.text = "•••• •••• •••• \(String(account.accountNumber?.suffix(4) ?? "----"))"
        accountTypeLabel.text = account.firstName?.uppercased() ?? "IVAN IVANOU"
        
        switch account.accountType {
        case "main":
            containerView.backgroundColor = UIColor(named: "primary_yellow")
            statusLabel.text = "АКТЫЎНА"
        case "credit":
            containerView.backgroundColor = UIColor(named: "card_gray")
            statusLabel.text = "НЕ АКТЫЎНА"
        case "foreign":
            containerView.backgroundColor = UIColor(named: "card_green")
            statusLabel.text = "АКТЫЎНА"
        default:
            containerView.backgroundColor = UIColor(named: "card_gray")
            statusLabel.text = "АКТЫЎНА"
        }
    }
}

