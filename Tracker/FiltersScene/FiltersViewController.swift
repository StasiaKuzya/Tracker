//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Анастасия on 06.03.2024.
//

import Foundation
import UIKit

protocol FiltersSelectionDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilterOption)
    func filtersVCDismissed(_ vc: FiltersViewController)
}

final class FiltersViewController: UIViewController {
    
    // MARK: -  Properties & Constants
    
    weak var filtersSelectionDelegate: FiltersSelectionDelegate?
    private let trackerVC: TrackerViewController
    var currentFilter: TrackerFilterOption?
    private var filterCategories: [TrackerFilterOption] = [
        .all,
        .today,
        .completed,
        .incompleted
    ]
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.allowsMultipleSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "categoryCell")
        return tableView
    }()

    var tableCount: CGFloat?
    
    init(trackerVC: TrackerViewController) {
        self.trackerVC = trackerVC
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("filterButton.title",
                                  comment: "Text displayed on filterButtonTitle")
        view.backgroundColor = .designWhite
        
        setupViews()
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
        
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = 75
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 4 * tableView.rowHeight),
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: - UITableViewDataSource

extension FiltersViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return filterCategories.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)  as? CategoryTableViewCell else {
            fatalError("Unable to dequeue CategoryTableViewCell")
        }
        let filterOption = filterCategories[indexPath.row]
        cell.textLabel?.text = filterOption.name
        
        // Установливаем галочку, если текущий фильтр совпадает с этим вариантом фильтра
        if filterOption ==  trackerVC.trackerFilterOption {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FiltersViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Снимаем выделение у других ячеек и устанавливаем галочку у выбранной
        for visibleIndexPath in tableView.indexPathsForVisibleRows ?? [] {
            if let cell = tableView.cellForRow(at: visibleIndexPath) {
                cell.accessoryType = (visibleIndexPath == indexPath) ? .checkmark : .none
            }
        }
        
        // Получаем выбранный фильтр
        let selectedFilter = filterCategories[indexPath.row]
        
        // Передаем выбранный фильтр через делегат и закрываем экран
        filtersSelectionDelegate?.didSelectFilter(selectedFilter)
        filtersSelectionDelegate?.filtersVCDismissed(self)
    }
}
