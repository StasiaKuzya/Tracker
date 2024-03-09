//
//  AlertModel.swift
//  Tracker
//
//  Created by Анастасия on 02.03.2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String?
    let primaryButton: AlertButton
    let additionalButtons: [AlertButton]?
}

struct AlertButton {
    let buttonText: String
    let completion: (() -> Void)?
}
