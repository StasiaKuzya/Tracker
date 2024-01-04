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
        trackerViewController.tabBarItem = UITabBarItem(title: "Трекеры",
                                                        image: UIImage(named: "trackerTabBarImage"),
                                                        selectedImage: nil)
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(title: "Статистика",
                                                        image: UIImage(named: "statTabBarImage"),
                                                        selectedImage: nil)
        
        self.viewControllers = [trackerViewController, statisticsViewController]
    }
    
    private func setupAppearance() {
        let appearance = UITabBarAppearance()

        appearance.backgroundColor = .designWhite
        tabBar.standardAppearance = appearance

        tabBar.tintColor = .designBlue
    }
}
