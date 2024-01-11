//
//  ViewController.swift
//  Tracker
//
//  Created by Анастасия on 04.01.2024.
//

import Foundation
import UIKit

final class TrackerViewController: UIViewController {
    
    // MARK: -  Properties & Constants
    
    private let buttonImage = UIImage(named: "addTracker")
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "DD.MM.YY"
        return formatter
    }()
    
    private let dateView: UIView = {
        let view = UIView()
        view.backgroundColor = .designLightGray
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .designBlack
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var emptyTrackerStateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let emptyTrackerStateImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "PlaceholderImage")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyTrackerStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textAlignment = .center
        label.textColor = .designBlack
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // TODO:
    private var trackers: [Tracker] = [] {
        didSet {
            updateUIForTrackers()
        }
    }
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .designWhite
        
        dateLabel.text = dateFormatter.string(from: Date())

        addTBViews()
        addNCViews()
        addSubViews()
        constraintsActivation()
    }
    
    // MARK: -  Private Methods
    
    private func addTBViews() {
        if let tabBarController = tabBarController {
            additionalSafeAreaInsets.bottom = tabBarController.tabBar.frame.size.height
        }
    }
    
    private func addNCViews() {
        if let navigationController = navigationController {
            let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                            target: self,
                                            action: #selector(addTrackerButtonTapped))
            addButton.tintColor = .designBlack

            dateView.addSubview(dateLabel)
            dateLabel.textAlignment = .center
            let dateBarButtonItem = UIBarButtonItem(customView: dateView)
            
            navigationItem.leftBarButtonItem = addButton
            navigationItem.rightBarButtonItem = dateBarButtonItem
            
            navigationController.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .always
            title = "Трекеры"
               navigationController.navigationBar.largeTitleTextAttributes = [
                   .foregroundColor: UIColor.designBlack,
                   .font: UIFont.systemFont(ofSize: 34, weight: .bold)
               ]
            
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Поиск"
        
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    private func addSubViews() {
        view.addSubview(dateView)
        
        emptyTrackerStateStackView.addArrangedSubview(emptyTrackerStateImage)
        emptyTrackerStateStackView.addArrangedSubview(emptyTrackerStateLabel)
        view.addSubview(emptyTrackerStateStackView)
    }
    
    private func constraintsActivation() {
        NSLayoutConstraint.activate([

            dateView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            dateView.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            dateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            dateView.heightAnchor.constraint(equalToConstant: 34),
            dateView.widthAnchor.constraint(equalToConstant: 77),

            dateLabel.centerXAnchor.constraint(equalTo: dateView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: dateView.centerYAnchor),
            
            emptyTrackerStateStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyTrackerStateStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
    
    private func updateUIForTrackers() {
        emptyTrackerStateLabel.isHidden = !trackers.isEmpty
        emptyTrackerStateImage.isHidden = !trackers.isEmpty
    }
    
    // MARK: - Methods
    
    @objc func addTrackerButtonTapped() {
    }
}

    // MARK: - UISearchResultsUpdating

extension TrackerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    }
}
