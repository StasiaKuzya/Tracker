//
//  NewHabitCreationViewController.swift
//  Tracker
//
//  Created by Анастасия on 12.01.2024.
//

import Foundation
import UIKit

final class NewHabitCreationViewController: UIViewController {

    // MARK: -  Properties & Constants
    
    private let words = ["Kатегория", "Paсписание"]
    private let maxLength = 38
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textField, tableView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 24
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.textColor = .designGray
        textField.backgroundColor = .designBackground
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.layer.cornerRadius = 16
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .designBackground
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        return tableView
    }()
    
    private lazy var stackViewH: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, creationButton])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let cancelButton: UIButton = {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Отменить", for: .normal)
        
        cancelButton.titleLabel?.tintColor = .designRed
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        cancelButton.backgroundColor = .designWhite
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.borderColor = UIColor.designRed.cgColor
        cancelButton.layer.cornerRadius = 16
        cancelButton.addTarget(
            self,
            action: #selector(cancelButtonTapped),
            for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        return cancelButton
    }()
    
    private let creationButton: UIButton = {
        let creationButton = UIButton(type: .system)
        creationButton.setTitle("Создать", for: .normal)
        
        creationButton.titleLabel?.tintColor = .designWhite
        creationButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        creationButton.backgroundColor = .designGray
        creationButton.layer.cornerRadius = 16
        creationButton.addTarget(
            self,
            action: #selector(creationButtonTapped),
            for: .touchUpInside)
        creationButton.translatesAutoresizingMaskIntoConstraints = false
        return creationButton
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        title = "Новая привычка"
        
        textField.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HabitTableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.separatorStyle = .singleLine
        setupViews()
        tableView.reloadData()
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.addSubview(stackView)
        view.addSubview(stackViewH)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            textField.heightAnchor.constraint(equalToConstant: 75),
            tableView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            stackViewH.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackViewH.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackViewH.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackViewH.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func showCategoryScreen() {
        let categoryManagementVC = CategoryManagementViewController()
        let categoryManagementNC = UINavigationController(rootViewController: categoryManagementVC)
        present(categoryManagementNC, animated: true, completion: nil)
    }
    private func showScheduleScreen() {
//        let categoryManagementVC = CategoryManagementViewController()
//        let navigationController = UINavigationController(rootViewController: categoryManagementVC)
//        present(navigationController, animated: true, completion: nil)
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func creationButtonTapped() {
//        guard let text = textField.text, text.count <= maxLength else {
//            return
//        }
    }
}

    // MARK: - UITableViewDataSource

extension NewHabitCreationViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return words.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? HabitTableViewCell else {
            fatalError("Unable to dequeue HabitCollectionViewCell")
        }
        cell.textLabel?.text = words[indexPath.section]
        return cell
    }
}

    // MARK: - UITableViewDelegate

extension NewHabitCreationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            showCategoryScreen()
        case 1:
            showScheduleScreen()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
}
    // MARK: - UITextFieldDelegate

extension NewHabitCreationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = .designBlack
    }
}
