//
//  QueryTableViewCell.swift
//  BugMeNot
//
//  Created by Khalid Asad on 4/3/21.
//  Copyright © 2021 Khalid Asad. All rights reserved.
//

import Foundation
import UIKit

final class QueryTableViewCell: UITableViewCell {
    
    let usernameLabel = UILabel.WrappedLabel
    let passwordLabel = UILabel.WrappedLabel
    let successRateLabel = UILabel.WrappedLabel
    let votesLabel = UILabel.WrappedLabel
    let ageLabel = UILabel.WrappedLabel
    let verticalStackView = UIStackView.VStack
    let horizontalStackView = UIStackView.HStack
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = ThemeManager.backgroundColor
        
        [usernameLabel, passwordLabel].forEach() {
            $0.font = ThemeManager.titleFont
        }
        
        [successRateLabel, votesLabel, ageLabel].forEach() {
            $0.font = ThemeManager.subTitleFont
        }
        
        [usernameLabel, passwordLabel, successRateLabel, votesLabel, ageLabel].forEach() {
            $0.textColor = ThemeManager.textColor
        }
        
        horizontalStackView.addArrangedSubviews([successRateLabel, votesLabel, ageLabel])
        verticalStackView.addArrangedSubviews([usernameLabel, passwordLabel, horizontalStackView])
        contentView.addSubview(verticalStackView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(login: QueryResponse) {
        usernameLabel.text = login.username
        passwordLabel.text = login.password
        successRateLabel.text = login.successRate
        votesLabel.text = login.votes
        ageLabel.text = login.age
    }
}

