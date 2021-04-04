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
    let successRateImageView = UIImageView.ImageView
    let votesImageView = UIImageView.ImageView
    let ageImageView = UIImageView.ImageView
    let successRateHorizontalStackView = UIStackView.HStack
    let votesHorizontalStackView = UIStackView.HStack
    let ageHorizontalStackView = UIStackView.HStack
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
        
        [successRateImageView, votesImageView, ageImageView].forEach() {
            $0.widthAnchor.constraint(equalToConstant: 16).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 16).isActive = true
            $0.tintColor = .white
        }
        
        let symbolConfiguration = UIImage.SymbolConfiguration(font: ThemeManager.subTitleFont)
        successRateImageView.image = UIImage(systemName: "chart.bar", withConfiguration: symbolConfiguration)
        votesImageView.image = UIImage(systemName: "hand.thumbsup", withConfiguration: symbolConfiguration)
        ageImageView.image = UIImage(systemName: "clock", withConfiguration: symbolConfiguration)
        
        [successRateHorizontalStackView, votesHorizontalStackView, ageHorizontalStackView].forEach() {
            $0.spacing = 4
        }
        
        successRateHorizontalStackView.addArrangedSubviews([successRateImageView, successRateLabel])
        votesHorizontalStackView.addArrangedSubviews([votesImageView, votesLabel])
        ageHorizontalStackView.addArrangedSubviews([ageImageView, ageLabel])
        
        horizontalStackView.alignment = .leading
        horizontalStackView.spacing = 10

        horizontalStackView.addArrangedSubviews([successRateHorizontalStackView, votesHorizontalStackView, ageHorizontalStackView])
        verticalStackView.addArrangedSubviews([usernameLabel, passwordLabel, horizontalStackView])
        
        verticalStackView.setCustomSpacing(12, after: passwordLabel)
        
        contentView.addConstraintSubview(verticalStackView, edgeInset: .init(top: 16, left: 16, bottom: -16, right: -16))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(login: QueryResponse) {
        usernameLabel.attributedText = login.formattedUsername
        passwordLabel.attributedText = login.formattedPassword
        successRateLabel.text = login.formattedSuccessRate
        votesLabel.text = login.formattedVotes
        ageLabel.text = login.formattedAge
    }
}
