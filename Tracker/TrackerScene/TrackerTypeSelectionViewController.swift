//
//  TrackerTypeSelectionViewController.swift
//  Tracker
//
//  Created by Анастасия on 12.01.2024.
//

import Foundation
import UIKit

protocol TrackerVCDataDelegate: AnyObject {
    func didUpdateTracker(_ tracker: Tracker)
    func trackerTypeSelectionVCDismissed(_ vc: TrackerTypeSelectionViewController)
}

final class TrackerTypeSelectionViewController: UIViewController {
    
    // MARK: -  Properties & Constants
    
    weak var delegate:TrackerVCDataDelegate?
    private let trackerVC = TrackerViewController()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [habitButton, irregularEventButton])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var habitButton: UIButton = {
        let habitButton = UIButton(type: .system)
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.titleLabel?.tintColor = .designWhite
        habitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        habitButton.addTarget(
            self,
            action: #selector(habitButtonTapped),
            for: .touchUpInside)
        habitButton.backgroundColor = .designBlack
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        habitButton.layer.cornerRadius = 16
        return habitButton
    }()
    
    private lazy var irregularEventButton: UIButton = {
        let irregularEventButton = UIButton(type: .system)
        irregularEventButton.setTitle("Нерегулярное событие", for: .normal)
        irregularEventButton.titleLabel?.tintColor = .designWhite
        irregularEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        irregularEventButton.addTarget(
            self,
            action: #selector(irregularEventButtonTapped),
            for: .touchUpInside)
        irregularEventButton.backgroundColor = .designBlack
        irregularEventButton.layer.cornerRadius = 16
        irregularEventButton.translatesAutoresizingMaskIntoConstraints = false
        return irregularEventButton
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        self.title = "Создание трекера"
        navigationController?.isNavigationBarHidden = false
        setupViews()
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        ])
    }
    
    private func showNewHabitCreationScreen() {
        let newHabitCreation = NewHabitCreationViewController()
        newHabitCreation.delegate = self
        newHabitCreation.title = "Новая привычка"
        let newHabitCreationNC = UINavigationController(rootViewController: newHabitCreation)
        present(newHabitCreationNC, animated: true, completion: nil)
    }
    
    private func showCategoryScreen() {
        let irreguralEventVC = IrreguralEventViewController()
        irreguralEventVC.delegate = self
        irreguralEventVC.title = "Новое нерегулярное событие"
        let irreguralEventNC = UINavigationController(rootViewController: irreguralEventVC)
        present(irreguralEventNC, animated: true, completion: nil)
    }
    
    
    // MARK: - Methods
    
    @objc func habitButtonTapped() {
        showNewHabitCreationScreen()
    }
    
    @objc func irregularEventButtonTapped() {
        showCategoryScreen()
    }
}

// MARK: - TrackerDataDelegate

extension TrackerTypeSelectionViewController: TrackerDataDelegate {
    
    func didCreateTracker(_ tracker: Tracker) {
        delegate?.didUpdateTracker(tracker)
        delegate?.trackerTypeSelectionVCDismissed(self)
    }
    
    func newHabitCreationVCDismissed(_ vc: NewHabitCreationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func ireguralEventVCDismissed(_ vc: IrreguralEventViewController) {
        dismiss(animated: true, completion: nil)
    }
}
