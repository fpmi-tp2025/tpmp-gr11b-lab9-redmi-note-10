//
//  MenuTableViewController.swift
//  LimoBank
//
//  Created by Екатерина on 27.05.25.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - Setup
    func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Настройка иконки
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor(named: "text_white")
        
        // Настройка заголовка
        titleLabel.textColor = UIColor(named: "text_white")
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        // Настройка стрелки
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = UIColor(named: "text_gray")
        arrowImageView.contentMode = .scaleAspectFit
    }
    
    // MARK: - Configuration
    func configure(title: String, icon: String) {
        titleLabel.text = title
        
        // Устанавливаем иконку (SF Symbols)
        iconImageView.image = UIImage(systemName: icon)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            backgroundColor = UIColor(named: "card_gray")?.withAlphaComponent(0.3)
        } else {
            backgroundColor = .clear
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            backgroundColor = UIColor(named: "card_gray")?.withAlphaComponent(0.3)
        } else {
            backgroundColor = .clear
        }
    }
}
