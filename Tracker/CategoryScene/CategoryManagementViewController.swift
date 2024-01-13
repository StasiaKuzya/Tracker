//
//  CategoryManagementViewController.swift
//  Tracker
//
//  Created by Анастасия on 13.01.2024.
//

import Foundation
import UIKit

final class CategoryManagementViewController: UIViewController {
    
    // MARK: -  Properties & Constants
    
    private var categories: [TrackerCategory] = []

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "categoryCell")
        return tableView
    }()

    private lazy var emptyTrackerStateStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emptyTrackerStateImage, emptyTrackerStateLabel])
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
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .designBlack
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.backgroundColor = .designBlack
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(
            self,
            action: #selector(addCategoryButtonTapped),
            for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Категории"
        view.backgroundColor = .white
        
        tableView.dataSource = self
        tableView.delegate = self

        setupViews()
        loadCategories()
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(emptyTrackerStateStackView)
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyTrackerStateStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyTrackerStateStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -(60 + 16) / 2),

            addButton.heightAnchor.constraint(equalToConstant: 60),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        ])

        tableView.isHidden = true
        emptyTrackerStateImage.isHidden = true
        addButton.isHidden = true
    }

    private func loadCategories() {
        // Загрузка категорий из хранилища

        if categories.isEmpty {
            // Если категорий нет, показываем заглушку и кнопку "Добавить категорию"
            emptyTrackerStateImage.isHidden = false
            addButton.isHidden = false
        } else {
            // Если есть категории, показываем таблицу
            tableView.isHidden = false
            tableView.reloadData()
        }
    }

    @objc private func addCategoryButtonTapped() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.delegate = self
        let newCategoryNC = UINavigationController(rootViewController: newCategoryVC)
        present(newCategoryNC, animated: true, completion: nil)
    }
}

    // MARK: - UITableViewDataSource

extension CategoryManagementViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].title
        return cell
    }
}
    // MARK: - UITableViewDelegate

extension CategoryManagementViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Обработка выбора категории
    }
}
    // MARK: - NewCategoryDelegate

extension CategoryManagementViewController: NewCategoryDelegate {
    func didAddCategory(_ category: TrackerCategory) {
        // Обработка добавления новой категории
        categories.append(category)
        loadCategories()
    }
}
