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
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        return searchController
    }()

    private var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .compact
        }
        picker.locale = Locale(identifier: "ru_RU")
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
    private var trackers: [Tracker] = []
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = Date()
    
    let params = GeometricParams(cellCount: 2,
                                 leftInset: 16,
                                 rightInset: 16,
                                 cellSpacing: 9)

    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
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
        view.backgroundColor = .designWhite
        
        addTBViews()
        addNCViews()
        setupViews()
        updateTrackersForDate()
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
            datePicker.addTarget(
                self,
                action: #selector(datePickerValueChanged),
                for: .valueChanged)
            
            navigationController.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .always
            title = "Трекеры"
               navigationController.navigationBar.largeTitleTextAttributes = [
                   .foregroundColor: UIColor.designBlack,
                   .font: UIFont.systemFont(ofSize: 34, weight: .bold)
               ]
        
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    private func setupViews() {
        emptyTrackerStateStackView.addArrangedSubview(emptyTrackerStateImage)
        emptyTrackerStateStackView.addArrangedSubview(emptyTrackerStateLabel)
        view.addSubview(collectionView)
        view.addSubview(emptyTrackerStateStackView)
        NSLayoutConstraint.activate([
            emptyTrackerStateStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyTrackerStateStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            datePicker.widthAnchor.constraint(equalToConstant: 120)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "cellTrackerCV")
        collectionView.register(SupplementaryTrackerView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.register(SupplementaryTrackerView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
    }
    
    @objc private func addTrackerButtonTapped() {
        showTrackerTypeSelectionScreen()
    }
    
    @objc private func datePickerValueChanged() {
        updateTrackersForDate()
    }
    
    private func showTrackerTypeSelectionScreen() {
        let trackerTypeSelectionVС = TrackerTypeSelectionViewController()
        trackerTypeSelectionVС.delegate = self
        let navigationController = UINavigationController(rootViewController: trackerTypeSelectionVС)
        present(navigationController, animated: true, completion: nil)
    }
}

    // MARK: - UISearchResultsUpdating

extension TrackerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    }
}

    // MARK: - UICollectionViewDataSource

extension TrackerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < visibleCategories.count else { return 0 }
        return visibleCategories[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("checking2 \(categories.count)")
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Создать ячейку
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellTrackerCV", for: indexPath) as? TrackerCollectionViewCell else { return UICollectionViewCell() }

        // Настроить ячейку
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
            
            cell.delegate = self
            let isCompletedToday = isTrackerCompletedToday(id: tracker.trackerId)
            let completedDays = completedTrackers.filter {
                $0.trackerID == tracker.trackerId
            }.count
            
            if  datePicker.date > Date() {
                cell.button.isEnabled = false
                cell.button.isHidden = true
                
            } else {
                cell.button.isEnabled = true
                cell.button.isHidden = false
            }
            
            cell.configure(
                with: tracker,
                completedForDate: isCompletedToday,
                completedDays: completedDays,
                indexPath: indexPath
            )

        // Возвратить ячейку
        return cell
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }
    
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
        return trackerRecord.trackerID  == id && isSameDay
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SupplementaryTrackerView else {
            fatalError("Failed to dequeue SupplementaryTrackerView")
        }

        if indexPath.section < visibleCategories.count {
            view.titleLabel.text = visibleCategories[indexPath.section].title
        } else {
            view.titleLabel.text = ""
        }

        return view
    }
}

    // MARK: - UICollectionViewDelegateFlowLayout

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                         withHorizontalFittingPriority: .required,
                                                         verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                let availableWidth = collectionView.frame.width - params.paddingWidth
                let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: cellWidth * 0.87)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: params.leftInset, bottom: 0, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
}

    // MARK: - UICollectionViewDelegate

extension TrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

    }
}

    // MARK: - TrackerVCDataDelegate

extension TrackerViewController: TrackerVCDataDelegate {
    
    func didUpdateTracker(_ tracker: Tracker) {

        if let existingCategoryIndex = categories.firstIndex(where: { $0.title == tracker.category }) {
            // Категория уже существует, добавляем трекер в существующую категорию
            categories[existingCategoryIndex].trackers.append(tracker)
        } else {
            // Категории не существует, создаем новую категорию и добавляем трекер
            let categoryTracker = TrackerCategory(
                title: tracker.category,
                trackers: [tracker]
            )
            categories.append(categoryTracker)
        }
        // Добавляем трекер к общему массиву
        updateTrackersForDate()
        trackers.append(tracker)

        // Обновляем UI
        collectionView.reloadData()
    }
    
    func trackerTypeSelectionVCDismissed(_ vc: TrackerTypeSelectionViewController) {
        dismiss(animated: true, completion: nil)
    }
}

    // MARK: - Extension updateTrackersForDate()

extension TrackerViewController {
    
    private func updateTrackersForDate() {
        currentDate = datePicker.date
        let selectedDayString = dayOfWeekString(for: currentDate)
        
        visibleCategories = categories.compactMap { category in
            let tracker = category.trackers.filter { tracker in
                guard !tracker.trackerSchedule.trackerScheduleDaysOfWeek.isEmpty else {
                    return true
                }
                return tracker.trackerSchedule.trackerScheduleDaysOfWeek.contains(selectedDayString)
            }
            if tracker.isEmpty {
                return nil
            }
            
            return TrackerCategory(
                title: category.title,
                trackers: tracker
            )
        }
        
        let containTrackers = visibleCategories.contains { category in
            return !category.trackers.isEmpty
        }
        
        updateUIForTrackers(containTrackers)
        collectionView.reloadData()
    }
    
    private func updateUIForTrackers(_ containTrackers: Bool) {
        emptyTrackerStateLabel.isHidden = containTrackers
        emptyTrackerStateImage.isHidden = containTrackers
    }
    
    private func dayOfWeekString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

// MARK: - Extension TrackerCellDelegate

extension TrackerViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(
            trackerID: id,
            date: datePicker.date)
        completedTrackers.append(trackerRecord)
        
        collectionView.reloadItems(at: [indexPath])
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        completedTrackers.removeAll { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
}
