//
//  AlertPresenter.swift
//  Tracker
//
//  Created by Анастасия on 02.03.2024.
//

import Foundation
import UIKit

final class AlertPresenter {
    static func showAlert(alertModel: AlertModel, delegate: UIViewController) {
        let alert = UIAlertController(title: alertModel.title,
                                      message: alertModel.message,
                                      preferredStyle: .actionSheet)
        
        alert.view.accessibilityIdentifier = "Alert"
        
        // Добавление основной кнопки
        let primaryAction = UIAlertAction(title: alertModel.primaryButton.buttonText, style: .destructive) { _ in
            alertModel.primaryButton.completion?()
        }
        alert.addAction(primaryAction)
        
        // Добавление дополнительных кнопок, если они есть
        if let additionalButtons = alertModel.additionalButtons {
            for button in additionalButtons {
                let additionalAction = UIAlertAction(title: button.buttonText, style: .default) { _ in
                    button.completion?()
                }
                alert.addAction(additionalAction)
            }
        }
        
        delegate.present(alert, animated: true, completion: nil)
    }
}
