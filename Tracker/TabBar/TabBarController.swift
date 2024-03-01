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
        
        let tabBarLineColor = UIColor { (traits: UITraitCollection) -> UIColor in
            if traits.userInterfaceStyle == .light {
                return UIColor.designLightGray
            } else {
                return .systemBackground
            }
        }
        let borderView = UIView(frame: CGRect(x: 0, y: 0, width: tabBar.frame.size.width, height: 2.0))
        borderView.backgroundColor = tabBarLineColor
        tabBar.addSubview(borderView)
    }
}
