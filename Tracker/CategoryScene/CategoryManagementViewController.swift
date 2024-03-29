//
//  CategoryManagementViewController.swift
//  Tracker
//
//  Created by Анастасия on 13.01.2024.
//

import Foundation
import UIKit

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategory)
    func categoryManagementVCDismissed(_ vc: CategoryManagementViewController)
}

final class CategoryManagementViewController: UIViewController {
    
    // MARK: -  Properties & Constants
    
    weak var categorySelectionDelegate: CategorySelectionDelegate?
    private var categories: [TrackerCategory] = []
    private var viewModel: CategoryManagementViewModel?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.allowsMultipleSelection = false
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
        label.text = NSLocalizedString("emptyTrackerStateLabel.title",
                                       comment: "Text displayed on emptyTrackerStateLabel, categoryScene")
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .designBlack
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
   private let addCategoryButtonTitle = NSLocalizedString("addCategoryButton.title",
                        comment: "Text displayed on addCategoryButtonTitle")
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(addCategoryButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.backgroundColor = .designBlack
        button.setTitleColor(.designWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(
            self,
            action: #selector(addCategoryButtonTapped),
            for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var tableCount: CGFloat?
    
    init(viewModel: CategoryManagementViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("categoryLabelTitle.title",
                                  comment: "Text displayed on categoryLabelTitle")
        view.backgroundColor = .designWhite
        
        setupViewModel()
        setupViews()
        loadCategories()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addUpperAndLowerBorders(to: tableView)
    }
    
    // MARK: - Private Methods
    
    private func addUpperAndLowerBorders(to view: UIView) {
        let upperBorderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 1.0))
        upperBorderView.backgroundColor = .designWhite
        view.addSubview(upperBorderView)
        
        let lowerBorderView = UIView(frame: CGRect(x: 0, y: view.frame.height - 1, width: view.frame.size.width, height: 1.0))
        lowerBorderView.backgroundColor = .designWhite
        view.addSubview(lowerBorderView)
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(emptyTrackerStateStackView)
        view.addSubview(addButton)
        
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            emptyTrackerStateStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyTrackerStateStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -(60 + 16) / 2),
            
            addButton.heightAnchor.constraint(equalToConstant: 60),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.isHidden = true
        emptyTrackerStateStackView.isHidden = true
    }
    
    private func loadCategories() {
        if categories.isEmpty {
            emptyTrackerStateStackView.isHidden = false
        } else {
            tableView.isHidden = false
            dinamicHeightOfTable()
            tableView.reloadData()
        }
    }
    
    private func dinamicHeightOfTable() {
        tableView.rowHeight = 75
        tableCount = CGFloat(categories.count)
        NSLayoutConstraint.activate([
            tableView.bottomAnchor.constraint(lessThanOrEqualTo: addButton.topAnchor, constant: -16),
            tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 75 * CGFloat(categories.count)),
        ])
    }
    
    private func setupViewModel() {
        viewModel = CategoryManagementViewModel(trackerCategoryStore: TrackerCategoryStore())

        viewModel?.didSelectCategoryClosure = { [weak self] category in
            self?.categorySelectionDelegate?.didSelectCategory(category)
        }

        viewModel?.categoryManagementVCDimissedClosure = { [weak self] in
            guard let self = self else { return }
            self.categorySelectionDelegate?.categoryManagementVCDismissed(self)
        }

        viewModel?.onCategoriesChange = { [weak self] categories in
            self?.categories = categories
            self?.tableView.reloadData()
        }
        viewModel?.onError = { error in
            print("Error: \(error.localizedDescription)")
        }
        viewModel?.fetchCategories()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)  as? CategoryTableViewCell else {
            fatalError("Unable to dequeue CategoryTableViewCell")
        }
        
        cell.textLabel?.text = categories[indexPath.row].title
        cell.accessoryType = .none
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoryManagementViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        viewModel?.didSelectCategory(at: indexPath.row)
    }
}

// MARK: - NewCategoryDelegate

extension CategoryManagementViewController: NewCategoryDelegate {
    func didAddCategory(_ category: TrackerCategory) {
        viewModel?.addCategoryToCD(category: category)
        viewModel?.fetchCategories()
        categories = viewModel?.categories ?? []
        loadCategories()
        emptyTrackerStateStackView.isHidden = true
    }
    
    func newCategoryVCDidCancel(_ vc: NewCategoryViewController) {
        dismiss(animated: true, completion: nil)
    }
}
