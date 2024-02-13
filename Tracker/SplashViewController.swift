//
//  SplashViewController.swift
//  Tracker
//
//  Created by Анастасия on 04.01.2024.
//

import Foundation
import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: -  Properties & Constants
    private let launchScreenImage: UIImageView = {
        let launchScreen = UIImageView()
        let imageForlaunchScreen = UIImage(named: "LaunchScreen")
        launchScreen.image = imageForlaunchScreen
        launchScreen.translatesAutoresizingMaskIntoConstraints = false
        return launchScreen
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = .designBlue
        
        view.addSubview(launchScreenImage)
        constraintsActivation()
        switchToTabBarController()
    }
    
    // MARK: -  Private Methods
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let onboardingVC = OnboardingViewController()
        window.rootViewController = onboardingVC
    }
    
    private func constraintsActivation() {
        NSLayoutConstraint.activate([
            launchScreenImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            launchScreenImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            launchScreenImage.heightAnchor.constraint(equalToConstant: 94),
            launchScreenImage.widthAnchor.constraint(equalToConstant: 91)
        ])
    }
}
