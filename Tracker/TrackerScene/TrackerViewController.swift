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
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "DD.MM.YY"
        return formatter
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)
//    private let datePicker = UIDatePicker()
    private var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.addTarget(self,
                         action: #selector(datePickerValueChanged(_:)),
                         for: .valueChanged)
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .compact
        }
        return picker
    }()
    
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
        
        addTBViews()
        addNCViews()
        setupViews()
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
            navigationItem.leftBarButtonItem = addButton
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
            
            navigationController.navigationBar.prefersLargeTitles = true
//            navigationItem.largeTitleDisplayMode = .automatic
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
    
    private func setupViews() {
        emptyTrackerStateStackView.addArrangedSubview(emptyTrackerStateImage)
        emptyTrackerStateStackView.addArrangedSubview(emptyTrackerStateLabel)
        view.addSubview(emptyTrackerStateStackView)
        NSLayoutConstraint.activate([
            emptyTrackerStateStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyTrackerStateStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
    
    private func updateUIForTrackers() {
        emptyTrackerStateLabel.isHidden = !trackers.isEmpty
        emptyTrackerStateImage.isHidden = !trackers.isEmpty
    }
    
    @objc private func addTrackerButtonTapped() {
        showTrackerTypeSelectionScreen()
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
    }
    
    private func showTrackerTypeSelectionScreen() {
        let trackerTypeSelectionVС = TrackerTypeSelectionViewController()
        let navigationController = UINavigationController(rootViewController: trackerTypeSelectionVС)
        present(navigationController, animated: true, completion: nil)
    }
}

    // MARK: - UISearchResultsUpdating

extension TrackerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    }
}
