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
        formatter.dateFormat = "DD.MM.YY"
        return formatter
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)

    private var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
//        picker.addTarget(self,
//                         action: #selector(datePickerValueChanged(_:)),
//                         for: .valueChanged)
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
   var trackers: [Tracker] = []
//    {
//        didSet {
//            updateUIForTrackers()
//        }
//    }
    private var filteredTrackers: [Tracker] = []
//    private var filteredTrackers = [Tracker]()

    private var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var selectedCategory: String?
    
    private var currentDate: Date = Date()
    
    let params = GeometricParams(cellCount: 2,
                                 leftInset: 16,
                                 rightInset: 16,
                                 cellSpacing: 7)

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
        
//        let shockTracker = Tracker(
//              trackerId: UUID(),
//              trackerName: "Трекер 1",
//              trackerColor: .red,
//              trackerEmoji: "😱",
//              trackerSchedule: TrackerSchedule(
//                  trackerScheduleDaysOfWeek: Set(DayOfWeek.allCases),
//                  trackerScheduleStartTime: Date(),
//                  trackerScheduleEndTime: Date().addingTimeInterval(60 * 60 * 2)
//              ),
//              trackerProgress: 0
//          )
//          trackers.append(shockTracker)
//          trackers.append(shockTracker)
//          trackers.append(shockTracker)
        
        addTBViews()
        addNCViews()
        setupViews()
        updateUIForTrackers()
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
                action: #selector(datePickerValueChanged(_:)),
                for: .valueChanged)
            
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
    
     func updateUIForTrackers() {
//        emptyTrackerStateLabel.isHidden = !trackers.isEmpty
//        emptyTrackerStateImage.isHidden = !trackers.isEmpty
         
        emptyTrackerStateLabel.isHidden = !filteredTrackers.isEmpty
        emptyTrackerStateImage.isHidden = !filteredTrackers.isEmpty
    }
        
    private func dayOfWeekString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date).capitalized
    }
    
    @objc private func addTrackerButtonTapped() {
        showTrackerTypeSelectionScreen()
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        print("selected date \(dayOfWeekString(for: currentDate))")
        
        updateUIForTrackersForDate()
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
//        return trackers.count
        return filteredTrackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Создать ячейку
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellTrackerCV", for: indexPath) as? TrackerCollectionViewCell else { return UICollectionViewCell() }
        
        // Настроить ячейку
        cell.prepareForReuse()
//        if indexPath.item < trackers.count {
//            cell.configure(with: trackers[indexPath.item])
        if indexPath.item < filteredTrackers.count {
             cell.configure(with: filteredTrackers[indexPath.item])
         }
        
        // Возвратить ячейку
        return cell
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
        
        view.isHidden = filteredTrackers.isEmpty
        view.titleLabel.text = selectedCategory
        print("header name \(String(describing: selectedCategory))")
        
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
        
        trackers.append(tracker)
//        updateUI()
        updateUIForTrackersForDate()
//        updateCollectionViewAnimated()
    }
    
    func trackerTypeSelectionVCDismissed(_ vc: TrackerTypeSelectionViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func selectedCategory(_ category: String) {
        DispatchQueue.main.async {
            self.selectedCategory = category
            print("header \(category)")
        }
    }
    
    func updateUIForTrackersForDate() {
        guard !trackers.isEmpty else {
            return
        }
        filteredTrackers = trackers.filter { tracker in
            let trackerDays = tracker.trackerSchedule.trackerScheduleDaysOfWeek
            let selectedDateString = dayOfWeekString(for: currentDate)
            return trackerDays.contains(selectedDateString)
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        updateUIForTrackers()
    }
    
//    func updateUI() {
//        DispatchQueue.main.async {
//            self.updateUIForTrackers()
//            self.updateUIForTrackersForDate()
//        }
//    }
    
//    func updateCollectionViewAnimated() {
//
//        let newTracker = self.filteredTrackers.count - 1
//        let indexPath = IndexPath(row: newTracker, section: 0)
//
//        self.collectionView.performBatchUpdates {
//            if !self.filteredTrackers.isEmpty {
//                self.collectionView.insertItems(at: [indexPath])
//            }
//        } completion: { [weak self] _ in
//            self?.updateSectionHeaderAnimated()
//        }
//    }
    
    func updateSectionHeaderAnimated() {
        guard let selectedCategory = selectedCategory else {
            return
        }
        let newTrackerCategory = TrackerCategory(title: selectedCategory, trackers: filteredTrackers)
        
        categories.append(newTrackerCategory)
        
        let sectionIndex = 0
        
        collectionView.performBatchUpdates({
            let newTracker = self.filteredTrackers.count - 1
            let indexPath = IndexPath(row: newTracker, section: sectionIndex)
            self.collectionView.insertItems(at: [indexPath])
            
            self.collectionView.reloadSections(IndexSet(integer: sectionIndex))
        }, completion: { _ in
        })
    }
    
//
//    func updateUIForTrackersForDate() {
//            guard !trackers.isEmpty else {
//                return
//            }
//
//            // Сохраняем индексы элементов, которые нужно удалить
//            let indicesToDelete = filteredTrackers.enumerated()
//                .filter { (index, tracker) in
//                    let trackerDays = tracker.trackerSchedule.trackerScheduleDaysOfWeek
//                    let selectedDateString = dayOfWeekString(for: currentDate)
//                    return !trackerDays.contains(selectedDateString)
//                }
//                .map { (index, tracker) in
//                    return IndexPath(row: index, section: 0)
//                }
//
//            // Удаляем элементы, которые не соответствуют выбранному дню
//            collectionView.deleteItems(at: indicesToDelete)
//
//            // Фильтруем трекеры
//            filteredTrackers = trackers.filter { tracker in
//                let trackerDays = tracker.trackerSchedule.trackerScheduleDaysOfWeek
//                let selectedDateString = dayOfWeekString(for: currentDate)
//                return trackerDays.contains(selectedDateString)
//            }
//
//            // Обновляем UI анимированно
//            DispatchQueue.main.async {
//                self.collectionView.performBatchUpdates({
//                    // Вставляем новые элементы
//                    let indicesToInsert = self.filteredTrackers.enumerated()
//                        .filter { (index, tracker) in
//                            return !self.collectionView.indexPathsForVisibleItems.contains { $0.item == index && $0.section == 0 }
//                        }
//                        .map { (index, tracker) in
//                            return IndexPath(row: index, section: 0)
//                        }
//
//                    self.collectionView.insertItems(at: indicesToInsert)
//                }, completion: { _ in
//                    // Завершаем обновление
//                    self.updateSectionHeaderAnimated()
//                })
//            }
//        }
}
