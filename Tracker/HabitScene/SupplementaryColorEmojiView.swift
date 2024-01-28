//
//  SupplementaryColorEmojiView.swift
//  Tracker
//
//  Created by Анастасия on 16.01.2024.
//

import Foundation
import UIKit

final class SupplementaryColorEmojiView: UICollectionReusableView {
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Emoji"
        titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
