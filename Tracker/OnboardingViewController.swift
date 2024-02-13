//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Анастасия on 12.02.2024.
//

import Foundation
import UIKit

class OnboardingViewController: UIPageViewController {
    
   // MARK: Properties
    
    private lazy var pages: [UIViewController] = {
        
        let blue = UIViewController()
        let red = UIViewController()

        setUpViews(for: blue,
                   image: "BlueOnboarding",
                   text: "Отслеживайте только то, что хотите")
        setUpViews(for: red,
                   image: "RedOnboarding",
                   text: "Даже если это не литры воды и йога")
        
        return [blue, red]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .designBlack
        pageControl.pageIndicatorTintColor = .designLightGray
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        setPageControl()
    }
    
    // MARK: Methods
    
    private func setPageControl() {
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setUpViews(for viewController: UIViewController,
                            image: String,
                            text: String
    ) {
        let imageView = UIImageView(image: UIImage(named: image))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
        ])
        
        let greatingLabel = UILabel()
        greatingLabel.text = text
        greatingLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        greatingLabel.numberOfLines = 2
        greatingLabel.textAlignment = .center
        greatingLabel.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(greatingLabel)
        NSLayoutConstraint.activate([
            greatingLabel.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -270),
            greatingLabel.trailingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            greatingLabel.leadingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        ])
        
        let startButton = UIButton(type: .system)
        startButton.setTitle("Вот это технологии", for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        startButton.backgroundColor = .designBlack
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 16
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(startButton)
        NSLayoutConstraint.activate([
            startButton.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            startButton.trailingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            startButton.leadingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            startButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
    }
    
    @objc private func startButtonTapped() {
        switchToTabBarController()
    }
    
}
// MARK: - UIPageViewControllerDataSource
    
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return pages[pages.count - 1]
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return pages[0]
        }
        return pages[nextIndex]
    }
}
// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
