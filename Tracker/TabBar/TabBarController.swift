//
//  TabBarController.swift
//  Tracker
//
//  Created by Анастасия on 04.01.2024.
//

import Foundation
import UIKit
 
final class TabBarController: UITabBarController {
    
    private let tabBarItem1 = NSLocalizedString("tabBarItem1.title", comment: "Text displayed on tabBar item 1")
    private let tabBarItem2 = NSLocalizedString("tabBarItem2.title", comment: "Text displayed on tabBar item 2")
    
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
        trackerNavigationController.tabBarItem = UITabBarItem(title: tabBarItem1,
                                                              image: UIImage(named: "trackerTabBarImage"),
                                                              selectedImage: nil)
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(title: tabBarItem2,
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
