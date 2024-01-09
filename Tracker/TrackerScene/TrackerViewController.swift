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
    
    private let addTrackerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(nil, for: .normal)
        button.tintColor = .designBlack
        button.addTarget(self, action: #selector(addTrackerButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let trackerMainLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.textAlignment = .center
        label.textColor = .designBlack
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    private let searchTextField: UISearchTextField = {
        let searchField = UISearchTextField()
        searchField.placeholder = "Поиск"
        searchField.backgroundColor = .designLightGray2
        searchField.translatesAutoresizingMaskIntoConstraints = false
        return searchField
    }()
    
    private let emptyTrackerStateView: UIView = {
        let view = UIView()
        view.backgroundColor = .designWhite
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    
    // TODO
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
        
        addTrackerButton.setImage(buttonImage, for: .normal)
        dateLabel.text = dateFormatter.string(from: Date())
        
        addSubViews()
        constraintsActivation()
    }
    
    // MARK: -  Private Methods
    
    private func addSubViews() {
        view.addSubview(addTrackerButton)
        view.addSubview(trackerMainLabel)
        view.addSubview(dateView)
        view.addSubview(dateLabel)
        view.addSubview(searchTextField)
        view.addSubview(emptyTrackerStateView)
        view.addSubview(emptyTrackerStateImage)
        view.addSubview(emptyTrackerStateLabel)
    }
    
    private func constraintsActivation() {
        NSLayoutConstraint.activate([
            addTrackerButton.heightAnchor.constraint(equalToConstant: 42),
            addTrackerButton.widthAnchor.constraint(equalToConstant: 42),
            addTrackerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6),
            addTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            
            trackerMainLabel.topAnchor.constraint(equalTo: addTrackerButton.bottomAnchor, constant: 1),
            trackerMainLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackerMainLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16),
            
            dateView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            dateView.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            dateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            dateView.heightAnchor.constraint(equalToConstant: 34),
            dateView.widthAnchor.constraint(equalToConstant: 77),
            

            dateLabel.centerXAnchor.constraint(equalTo: dateView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: dateView.centerYAnchor),
            
            searchTextField.topAnchor.constraint(equalTo: trackerMainLabel.bottomAnchor, constant: 7),
            searchTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            emptyTrackerStateView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            emptyTrackerStateView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            emptyTrackerStateView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            emptyTrackerStateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            
            
            emptyTrackerStateImage.heightAnchor.constraint(equalToConstant: 80),
            emptyTrackerStateImage.widthAnchor.constraint(equalToConstant: 80),
            emptyTrackerStateImage.centerXAnchor.constraint(equalTo: emptyTrackerStateView.centerXAnchor),
            emptyTrackerStateImage.topAnchor.constraint(greaterThanOrEqualTo: emptyTrackerStateView.topAnchor, constant: 220),
            
            
            emptyTrackerStateLabel.leadingAnchor.constraint(equalTo: emptyTrackerStateView.leadingAnchor, constant: 16),
            emptyTrackerStateLabel.trailingAnchor.constraint(equalTo: emptyTrackerStateView.trailingAnchor, constant: -16),
            emptyTrackerStateLabel.topAnchor.constraint(equalTo: emptyTrackerStateImage.bottomAnchor, constant: 8),
            emptyTrackerStateLabel.bottomAnchor.constraint(greaterThanOrEqualTo: emptyTrackerStateView.bottomAnchor, constant: -275),

            
        ])
    }
    
    private func updateUIForTrackers() {
        emptyTrackerStateView.isHidden = !trackers.isEmpty
        emptyTrackerStateLabel.isHidden = !trackers.isEmpty
        emptyTrackerStateImage.isHidden = !trackers.isEmpty
    }
    
    // MARK: -  Methods
    
    @objc func addTrackerButtonTapped() {
    }
}
