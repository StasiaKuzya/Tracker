//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Анастасия on 16.01.2024.
//

import Foundation
import UIKit

final class ColorEmojiCollectionViewCell: UICollectionViewCell {
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 32)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureColor(_ color: UIColor) {
        imageView.image = UIImage(named: "UnpickedColorImage")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = color
    }
    
    func pickConfiguredColor(_ color: UIColor) {
        imageView.image = UIImage(named: "PickedColorImage")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = color
    }
}
