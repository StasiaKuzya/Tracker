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
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    var trackerFilterOption: TrackerFilterOption = .all
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.placeholder = NSLocalizedString("searchTextField.title",
                                                  comment: "Text displayed on searchTextField, main scene")
        textField.backgroundColor = .designBackground
        textField.textColor = .designBlack
        textField.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        textField.autocapitalizationType = .none
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
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
        label.text = NSLocalizedString("emptyState.title",
                                       comment: "Text displayed on emptyState, main scene")
        label.textAlignment = .center
        label.textColor = .designBlack
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var wrongTextSearchStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [wrongTextSearchStackViewImage, ewrongTextSearchStackViewLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let wrongTextSearchStackViewImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "TextFieldPlaceholder")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let ewrongTextSearchStackViewLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("wrongSearchState.title",
                                       comment: "Text displayed on wrongSearchState, main scene")
        label.textAlignment = .center
        label.textColor = .designBlack
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(
            NSLocalizedString("filterButton.title",
                              comment: "Text displayed on filterButtonTitle, main scene"),
            for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.backgroundColor = .designBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(
            self,
            action: #selector(filterButtonTapped),
            for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

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
        view.backgroundColor = .systemBackground
        
        addTBViews()
        addNCViews()
        setupViews()
        trackers = try! trackerStore.fetchTrackers()
        categories = trackerCategoryStore.fetchAllCategories()
        completedTrackers = trackerRecordStore.fetchAllTrackerRecords()
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
            title = NSLocalizedString("mainLargeTitle.title",
                                      comment: "Text displayed on mainLargeTitle, main scene")
            navigationController.navigationBar.largeTitleTextAttributes = [
                .foregroundColor: UIColor.designBlack,
                .font: UIFont.systemFont(ofSize: 34, weight: .bold)
            ]
        }
    }
    
    private func setupViews() {
        emptyTrackerStateStackView.addArrangedSubview(emptyTrackerStateImage)
        emptyTrackerStateStackView.addArrangedSubview(emptyTrackerStateLabel)
        view.addSubview(collectionView)
        view.addSubview(emptyTrackerStateStackView)
        view.addSubview(wrongTextSearchStackView)
        view.addSubview(searchTextField)
        view.addSubview(filterButton)
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
            searchTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            
            emptyTrackerStateStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyTrackerStateStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 46),
            
            wrongTextSearchStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            wrongTextSearchStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 46),
            
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            datePicker.widthAnchor.constraint(equalToConstant: 120),
            
            filterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -additionalSafeAreaInsets.bottom - 16),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
            
        ])
        print("bottom \(additionalSafeAreaInsets.bottom)")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "cellTrackerCV")
        collectionView.register(SupplementaryTrackerView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.register(SupplementaryTrackerView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
    }
    
    @objc private func addTrackerButtonTapped() {
        showTrackerTypeSelectionScreen()
    }
    
    private func showTrackerTypeSelectionScreen() {
        let trackerTypeSelectionVС = TrackerTypeSelectionViewController()
        trackerTypeSelectionVС.delegate = self
        let navigationController = UINavigationController(rootViewController: trackerTypeSelectionVС)
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc private func datePickerValueChanged() {
        updateTrackersForDate()
    }
    
    @objc private func filterButtonTapped() {
        let filtersVC = FiltersViewController()
        filtersVC.filtersSelectionDelegate = self
        let filtersNC = UINavigationController(rootViewController: filtersVC)
        present(filtersNC, animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate

extension TrackerViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        updateTrackersForDate()
        return true
    }
}

// MARK: - UICollectionViewDataSource

extension TrackerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < visibleCategories.count else { return 0 }
        return visibleCategories[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
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
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        highlightPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else {
            return nil
        }
        let parameters = UIPreviewParameters()
        let previewView = UITargetedPreview(view: cell.colorView, parameters: parameters)
        return previewView
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else {
            return nil
        }
        
        let indexPath = indexPaths[0]
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        return UIContextMenuConfiguration(actionProvider: { actions in
            let pinTitle = NSLocalizedString(tracker.isPinned ? "unpinTracker.title" : "pinTracker.title",
                                            comment: "Text displayed on pinTracker, main scene")
            let editTitle = NSLocalizedString("editTracker.title",
                                            comment: "Text displayed on editTracker, main scene")
            let deleteTitle = NSLocalizedString("deleteTracker.title",
                                            comment: "Text displayed on deleteTracker, main scene")
            
            let deleteAction = UIAction(title: deleteTitle) { [weak self] _ in
                self?.deleteTracker(indexPath: indexPath)
            }
            deleteAction.attributes = .destructive
            
            return UIMenu(children: [
                UIAction(title: pinTitle) { [weak self] _ in
                    self?.pinTracker(indexPath: indexPath)
                },
                UIAction(title: editTitle) { [weak self] _ in
                    self?.editTracker(indexPath: indexPath)
                },
                deleteAction
            ])
        })
    }
    
    // Pin Tracker Logic
    private func pinTracker(indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        togglePinStatus(for: tracker)
    }
    
    private func togglePinStatus(for tracker: Tracker) {
        guard let index = trackers.firstIndex(where: { $0.trackerId == tracker.trackerId }) else {
            return
        }
        trackers[index].isPinned.toggle()
        didUpdateEditedTracker(trackers[index])
        updateUIAfterActions()
    }
    
    // Edit Tracker Logic
    private func editTracker(indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        showEditTrackerScreen(for: tracker)
        updateUIAfterActions()
    }
    
    private func showEditTrackerScreen(for tracker: Tracker) {
        let editTrackerVC = EditTrackerViewController(tracker: tracker)
        editTrackerVC.delegate = self
        let editTrackerNC = UINavigationController(rootViewController: editTrackerVC)
        present(editTrackerNC, animated: true, completion: nil)
    }
    
    // Delete Tracker Logic
    private func deleteTracker(indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        showDeleteAlert(tracker: tracker)
    }
    
    private func showDeleteAlert(tracker: Tracker) {
        let alertModel = AlertModel(
            title: NSLocalizedString("alertDeleteTracker.title",
                                     comment: "Text displayed on alertDeleteTracker, main scene"),
            message: nil,
            primaryButton: AlertButton(
                buttonText: NSLocalizedString("alertDeleteButton1.title",
                                              comment: "Text displayed on alertDeleteButton1, main scene"),
                completion: { [weak self] in
                    self?.deleteTrackersToCD(tracker: tracker)
                    self?.updateUIAfterActions()
                }
            ),
            additionalButtons: [AlertButton(
                buttonText: NSLocalizedString("alertDeleteButton2.title",
                                              comment: "Text displayed on alertDeleteButton2, main scene"),
                completion: nil
            )]
        )
        
        AlertPresenter.showAlert(alertModel: alertModel, delegate: self)
    }
    
    private func deleteTrackersToCD(tracker: Tracker) {
        do {
            try trackerStore.deleteTracker(tracker)
        } catch let error as NSError {
            print("Failed to delete tracker from Core Data: \(error)")
        }
    }
    
    private func updateUIAfterActions() {
        // Обновление UI
        updateTrackersForDate()
        collectionView.reloadData()
    }
}

// MARK: - TrackerVCDataDelegate

extension TrackerViewController: TrackerVCDataDelegate {
        
    func didUpdateTracker(_ tracker: Tracker) {
        // Добавление трекера в Core Data
        addTrackersToCD(tracker: tracker)
        
        // Обновление категорий
        if let existingCategoryIndex = categories.firstIndex(where: { $0.title == tracker.category }) {
            categories[existingCategoryIndex].trackers.append(tracker)
        } else {
            let categoryTracker = TrackerCategory(
                title: tracker.category,
                trackers: [tracker]
            )
            categories.append(categoryTracker)
        }
        
        // Обновление UI
        updateUIAfterActions()
    }
    
    private func addTrackersToCD(tracker: Tracker) {
        do {
            try trackerStore.addTracker(tracker)
        } catch let error as NSError {
            print("Failed to add tracker to Core Data: \(error)")
            if let detailedErrors = error as? [NSError] {
                for detailedError in detailedErrors {
                    print("Detailed error: \(detailedError.userInfo)")
                }
            } else {
                print("No detailed errors")
            }
        }
    }
    
    func trackerTypeSelectionVCDismissed(_ vc: TrackerTypeSelectionViewController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Extension updateTrackersForDate()

extension TrackerViewController {
    
    private func updateTrackersForDate() {
        currentDate = datePicker.date
        let selectedDayNumber = dayOfWeekNumber(for: currentDate)
        let filtredText = (searchTextField.text ?? "").lowercased()
        
        // Извлекаем данные из Core Data
        extractDataFromCD()
        
        // Сохранение категории и их закрепленные трекеры
        var updatedCategories: [TrackerCategory] = []
        var pinnedTrackers: [Tracker] = []
        
//        for category in categories {
//            let filteredTrackers = category.trackers.filter { tracker in
//                guard !tracker.trackerSchedule.trackerScheduleDaysOfWeek.isEmpty else {
//                    return true
//                }
//                
//                let textCondition = filtredText.isEmpty ||
//                tracker.trackerName.lowercased().contains(filtredText)
//                let trackerCondition = tracker.trackerSchedule.trackerScheduleDaysOfWeek.contains { $0.numberDay == selectedDayNumber } || tracker.trackerSchedule.trackerScheduleDaysOfWeek.isEmpty
//                
//                return textCondition && trackerCondition
//            }
        for category in categories {
        let filteredTrackers = category.trackers.filter { tracker in
            let trackerCondition: Bool
            switch trackerFilterOption {
                //TODO: 
            case .all, .today:
                if trackerFilterOption == .today {
                    datePicker.setDate(Date(), animated: true)
                    collectionView.reloadData()
                }
                trackerCondition = tracker.trackerSchedule.trackerScheduleDaysOfWeek.contains { $0.numberDay == selectedDayNumber }
            case .completed:
                trackerCondition = completedTrackers.contains {
                    $0.trackerID == tracker.trackerId
                    && Calendar.current.isDate($0.date, inSameDayAs: datePicker.date)
                }
            case .incompleted:
                trackerCondition = completedTrackers.contains {
                    $0.trackerID != tracker.trackerId
                    && Calendar.current.isDate($0.date, inSameDayAs: datePicker.date)
                }
            }
            
            let textCondition = filtredText.isEmpty || tracker.trackerName.lowercased().contains(filtredText)
            
            return textCondition && trackerCondition
        }
            // Разделение трекеров на закрепленные и обычные
            let (pinned, regular) = filteredTrackers.reduce(into: ([Tracker](), [Tracker]())) { result, tracker in
                if tracker.isPinned {
                    result.0.append(tracker)
                } else {
                    result.1.append(tracker)
                }
            }
            pinnedTrackers.append(contentsOf: pinned)
            
            // Создание категории только с обычными трекерами
            if !regular.isEmpty {
                updatedCategories.append(TrackerCategory(title: category.title, trackers: regular))
            }
        }
        
        // Добавление категории с закрепленными трекерами
        if !pinnedTrackers.isEmpty {
            let pinnedCategory = TrackerCategory(
                title: NSLocalizedString("pinnedCategory.title",
                                         comment: "Text displayed on pinnedCategoryTitle, main scene"),
                trackers: pinnedTrackers)
            updatedCategories.insert(pinnedCategory, at: 0)
        }
        categories = updatedCategories
        visibleCategories = updatedCategories
        
        let containTrackers = visibleCategories.contains { category in
            return !category.trackers.isEmpty
        }
        
        updateUIForTrackers(containTrackers)
        collectionView.reloadData()
    }
    
    private func dayOfWeekNumber(for date: Date) -> Int {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        // Числовое представление дня недели, где вс - 1
        return dayOfWeek
    }
    
    private func extractDataFromCD() {
        do {
            // Извлекаем трекеры из Core Data
            let coreDataTrackers = try trackerStore.fetchTrackers()
            trackers = coreDataTrackers.map { coreDataTrackers in
                return coreDataTrackers
            }
            // Извлекаем категории из Core Data
            let coreDataTrackersCategories = trackerCategoryStore.fetchAllCategories()
            categories = coreDataTrackersCategories.map { coreDataTrackersCategory in
                return coreDataTrackersCategory
            }

            // Проходим по каждой категории
            for categoryIndex in categories.indices {
                // Фильтруем трекеры, которые принадлежат текущей категории
                let categoryTrackers = coreDataTrackers.filter { tracker in
                    return tracker.category.lowercased() == categories[categoryIndex].title.lowercased()
                }

                categories[categoryIndex].trackers = categoryTrackers
            }
        } catch {
            print("Failed to fetch trackers from Core Data: \(error)")
            return
        }
    }
    
    private func updateUIForTrackers(_ containTrackers: Bool) {
        guard let searchTextField = searchTextField.text else { return }
        
        if (!containTrackers || categories.isEmpty) && searchTextField.isEmpty {
            emptyTrackerStateStackView.isHidden = false
            wrongTextSearchStackView.isHidden = true
        } else if !containTrackers && !categories.isEmpty && searchTextField.isEmpty{
            emptyTrackerStateStackView.isHidden = false
            wrongTextSearchStackView.isHidden = true
        } else if containTrackers && !categories.isEmpty && searchTextField.isEmpty{
            emptyTrackerStateStackView.isHidden = true
            wrongTextSearchStackView.isHidden = true
        } else if containTrackers && !searchTextField.isEmpty{
            emptyTrackerStateStackView.isHidden = true
            wrongTextSearchStackView.isHidden = true
        } else {
            emptyTrackerStateStackView.isHidden = true
            wrongTextSearchStackView.isHidden = false
        }
    }
}

// MARK: - Extension TrackerCellDelegate

extension TrackerViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(
            trackerID: id,
            date: datePicker.date)
        completedTrackers.append(trackerRecord)
        addRecordedTrackersToCD(trackerRecord: trackerRecord)
        
        collectionView.reloadItems(at: [indexPath])
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        if let indexToDelete = completedTrackers.firstIndex(where: {
            isSameTrackerRecord(trackerRecord: $0, id: id)
        }) {
            let trackerRecordToDelete = completedTrackers[indexToDelete]
            deleteRecordedTrackersToCD(trackerRecord: trackerRecordToDelete)
            completedTrackers.remove(at: indexToDelete)
        }
        collectionView.reloadItems(at: [indexPath])
    }
    
    private func addRecordedTrackersToCD(trackerRecord: TrackerRecord) {
        do {
            try trackerRecordStore.addTracker(trackerRecord)
        } catch let error as NSError {
            print("Failed to add tracker to Core Data: \(error)")
        }
    }
    
    private func deleteRecordedTrackersToCD(trackerRecord: TrackerRecord) {
        do {
            try trackerRecordStore.deleteTrackerRecord(trackerRecord)
        } catch let error as NSError {
            print("Failed to add tracker to Core Data: \(error)")
        }
    }
}

// MARK: - Extension TrackerEditDataDelegate

extension TrackerViewController: TrackerEditDataDelegate {
    func editTrackerVCDismissed(_ vc: EditTrackerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didUpdateEditedTracker(_ updatedTracker: Tracker) {
        updateTracker(updatedTracker)
        updateUIAfterActions()
    }
    
    func updateTracker(_ editedTracker: Tracker) {
        do {
            guard let trackerCoreData = try trackerStore.fetchTrackerByIdForRecords(editedTracker.trackerId) else {
                print("Трекер с ID \(editedTracker.trackerId) не найден в Core Data")
                return
            }
            // Внесены изменения в свойства объекта трекера в Core Data
            trackerStore.updateExistingTracker(trackerCoreData, with: editedTracker)
            print("Данные по трекеру успешно обновлены")
            
        } catch {
            print("Ошибка при обновлении данных по трекеру: \(error)")
        }
    }
}

// MARK: - Extension FiltersSelectionDelegate

extension TrackerViewController: FiltersSelectionDelegate {
    func didSelectFilter(_ filter: TrackerFilterOption) {
        print("filter \(filter)")
        trackerFilterOption = filter
        updateTrackersForDate()
    }
    
    func filtersVCDismissed(_ vc: FiltersViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func switchToCompletedTrackers() {
        trackerFilterOption = .completed
        updateTrackersForDate()
    }

    func switchToIncompleteTrackers() {
        trackerFilterOption = .incompleted
        updateTrackersForDate()
    }
}
