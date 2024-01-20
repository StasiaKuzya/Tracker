//
//  SupplementaryTrackerView.swift
//  Tracker
//
//  Created by Анастасия on 15.01.2024.
//

import Foundation
import UIKit

final class SupplementaryTrackerView: UICollectionReusableView {
    var titleLabel: UILabel = {
        let titleLabel = UILabel()
//        titleLabel.text = "Категория"
        titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
