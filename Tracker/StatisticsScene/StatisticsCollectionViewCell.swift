//
//  StatisticsCollectionViewCell.swift
//  Tracker
//
//  Created by Анастасия on 03.03.2024.
//

import Foundation
import UIKit

final class StatisticsCollectionViewCell: UICollectionViewCell {
    // MARK: -  Properties & Constants
    private lazy var statStV: UIStackView = {
        let stackViewV = UIStackView(arrangedSubviews: [statNumberLabel, statNameLabel])
        stackViewV.axis = .vertical
        stackViewV.alignment = .leading
        stackViewV.spacing = 8
        stackViewV.distribution = .fill
        stackViewV.backgroundColor = .systemBackground
        stackViewV.layer.cornerRadius = 16
        stackViewV.translatesAutoresizingMaskIntoConstraints = false
        return stackViewV
    }()
    
    private let statNumberLabel: UILabel = {
        let statNumberLabel = UILabel()
        statNumberLabel.font = .systemFont(ofSize: 32, weight: .bold)
        statNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        return statNumberLabel
    }()
    
    private let statNameLabel: UILabel = {
        let statNameLabel = UILabel()
        statNameLabel.font = .systemFont(ofSize: 12)
        statNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return statNameLabel
    }()
    
    private let blankView: UIView = {
        let blankView = UIView()
        blankView.backgroundColor = .systemBackground
        blankView.layer.cornerRadius = 16
        blankView.translatesAutoresizingMaskIntoConstraints = false
        return blankView
    }()
    // MARK: -  Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -  Methods
    func setupViews() {
        setGradientBorder()
        contentView.addSubview(blankView)
        contentView.addSubview(statStV)
        
        // Настройка констрейнтов
        NSLayoutConstraint.activate([
            blankView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            blankView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
            blankView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1),
            blankView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1),
            
            statStV.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            statStV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            statStV.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            statStV.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }
    
    func setGradientBorder() {
        // Создаем градиентные цвета
        let colorLeft = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
        let colorMiddle = UIColor(red: 0.0/255.0, green: 255.0/255.0, blue: 50.0/255.0, alpha: 1.0).cgColor
        let colorRight = UIColor(red: 0.0/255.0, green: 120.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        
        // Создаем градиентный слой
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorLeft,colorMiddle, colorRight]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.size.width, height: self.contentView.frame.size.height)

        
        // Создаем рамку вокруг слоя
        let borderLayer = CALayer()
        borderLayer.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.size.width, height: self.contentView.frame.size.height)
        borderLayer.cornerRadius = 16
        borderLayer.masksToBounds = true
        borderLayer.addSublayer(gradientLayer)
        
        // Вставляем готовую рамку в представление
        self.contentView.layer.insertSublayer(borderLayer, at: 0)
    }
    
    func configure(with data: CellStatData) {
        statNumberLabel.text = "\(data.value)"
        statNameLabel.text = data.title
    }
}
