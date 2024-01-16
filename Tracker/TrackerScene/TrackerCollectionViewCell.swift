//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Анастасия on 12.01.2024.
//

import Foundation
import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    private let colorView: UIView = {
        let colorView = UIView()
        colorView.backgroundColor = .designBlue
        colorView.layer.cornerRadius = 16
        colorView.translatesAutoresizingMaskIntoConstraints = false
        return colorView
    }()
    
    private lazy var stackViewV: UIStackView = {
        let stackViewV = UIStackView(arrangedSubviews: [emojiLabel, nameLabel])
        stackViewV.axis = .vertical
        stackViewV.alignment = .fill
        stackViewV.spacing = 8
        stackViewV.distribution = .fill
        stackViewV.backgroundColor = colorView.backgroundColor
        stackViewV.layer.cornerRadius = 16
        stackViewV.translatesAutoresizingMaskIntoConstraints = false
        return stackViewV
    }()
    
    var emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        return emojiLabel
    }()
    
    var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        nameLabel.textColor = .designWhite
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
    }()
    
    private lazy var stackViewH: UIStackView = {
        let stackViewH = UIStackView(arrangedSubviews: [daysCountLabel, button])
        stackViewH.axis = .horizontal
        stackViewH.alignment = .fill
        stackViewH.spacing = 8
        stackViewH.distribution = .fill
        stackViewH.translatesAutoresizingMaskIntoConstraints = false
        return stackViewH
    }()
    
    let daysCountLabel: UILabel = {
        let daysCountLabel = UILabel()
        daysCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        daysCountLabel.textColor = .designBlack
        daysCountLabel.translatesAutoresizingMaskIntoConstraints = false
        return daysCountLabel
    }()
    
    var button: UIButton = {
        let button = UIButton(type: .system)
        let addButtonImage = UIImage(named: "AddButton")
        button.setImage(addButtonImage, for: .normal)
        button.tintColor = .designBlue
        button.addTarget(
            self,
            action: #selector(buttonTapped),
            for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        colorView.addSubview(stackViewV)
        contentView.addSubview(colorView)
        contentView.addSubview(stackViewH)
        
        // Настройка констрейнтов
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),
            
            stackViewV.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            stackViewV.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            stackViewV.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            stackViewV.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),
            
            stackViewH.topAnchor.constraint(equalTo: stackViewV.bottomAnchor, constant: 20),
            stackViewH.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            stackViewH.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stackViewH.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
//
        ])
    }

    func configure(with tracker: Tracker) {
        // Настройка элементов интерфейса
        emojiLabel.text = tracker.trackerEmoji
        nameLabel.text = tracker.trackerName
        daysCountLabel.text = "0 дней"
//        button.setTitle("+", for: .normal)
    }
    
    @objc private func buttonTapped() {
        print("Button tapped!")
    }
}
