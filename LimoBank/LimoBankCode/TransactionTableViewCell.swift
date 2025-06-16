//
//  TransactionTableViewCell.swift
//  LimoBank
//
//  Created by Daniil Zharnasek on 26.05.25.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        iconImageView.layer.cornerRadius = 15
        iconImageView.contentMode = .scaleAspectFit
        
        titleLabel.textColor = UIColor(named: "text_white")
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        dateLabel.textColor = UIColor(named: "text_gray")
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        
        amountLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    func configure(with transaction: Transaction) {
        titleLabel.text = transaction.description
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy HH:mm"
        dateLabel.text = "09.06.25 11:12"
        if transaction.amount > 0 {
            amountLabel.text = "+\(String(format: "%.1f", transaction.amount)) byn"
            amountLabel.textColor = UIColor(named: "card_green")
            iconImageView.backgroundColor = UIColor(named: "card_green")
        } else {
            amountLabel.text = "\(String(format: "%.1f", transaction.amount)) byn"
            amountLabel.textColor = UIColor(named: "text_white")
            iconImageView.backgroundColor = .systemRed
        }
        
        // Устанавливаем иконку в зависимости от категории
        switch transaction.category {
        case "transport":
            iconImageView.image = UIImage(named: "transport_icon")
        case "coffee":
            iconImageView.image = UIImage(named: "cofix_icon")
        case "income":
            iconImageView.image = UIImage(systemName: "plus.circle.fill")
        default:
            iconImageView.image = UIImage(systemName: "circle.fill")
        }
    }
}
