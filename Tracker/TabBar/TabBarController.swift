//
//  TabBarController.swift
//  Tracker
//
//  Created by Анастасия on 04.01.2024.
//

import Foundation
import UIKit
 
final class TabBarController: UITabBarController {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabs()
        setupAppearance()
    }
    
    // MARK: -  Private Methods
    
    private func setUpTabs() {
        
        let trackerViewController = TrackerViewController()
        let trackerNavigationController = UINavigationController(rootViewController: trackerViewController)
        trackerNavigationController.tabBarItem = UITabBarItem(title: "Трекеры",
                                                        image: UIImage(named: "trackerTabBarImage"),
                                                        selectedImage: nil)
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(title: "Статистика",
                                                        image: UIImage(named: "statTabBarImage"),
                                                        selectedImage: nil)
        
        self.viewControllers = [trackerNavigationController, statisticsViewController]
    }
    
    private func setupAppearance() {
        let appearance = UITabBarAppearance()

        appearance.backgroundColor = .designWhite
        tabBar.standardAppearance = appearance

        tabBar.tintColor = .designBlue
        
        tabBar.layer.borderWidth = 1.0
        tabBar.layer.borderColor = UIColor.lightGray.cgColor
    }
}
