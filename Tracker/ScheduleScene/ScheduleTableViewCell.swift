//
//  ScheduleTableViewCell.swift
//  Tracker
//
//  Created by Анастасия on 14.01.2024.
//

import Foundation
import UIKit

final class ScheduleTableViewCell: UITableViewCell {
    
    let dayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let switchControl: UISwitch = {
        let switchControl = UISwitch()
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(false, animated: true)
        switchControl.onTintColor = .designBlue
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        backgroundColor = .designBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(dayLabel)
        addSubview(switchControl)

        NSLayoutConstraint.activate([
            dayLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            switchControl.centerYAnchor.constraint(equalTo: centerYAnchor),
            switchControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }    
}
