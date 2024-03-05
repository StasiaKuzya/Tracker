//
//  EditHabitViewController.swift
//  Tracker
//
//  Created by Анастасия on 02.03.2024.
//

import Foundation
import UIKit

protocol TrackerEditDataDelegate: AnyObject {
    func editTrackerVCDismissed(_ vc: EditTrackerViewController)
    func didUpdateEditedTracker(_ updatedTracker: Tracker)
}

final class EditTrackerViewController: UIViewController {
    
    // MARK: -  Properties & Constants
    weak var delegate: TrackerEditDataDelegate?
    private let categoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private var selectedIndexes: [Int: Int] = [:]
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var tracker: Tracker
    
    private var words: [(title: String, subtitle: String?)] = [
        (NSLocalizedString("categoryTable.title",
                            comment: "Text displayed on categoryTable"),
         nil),
        (NSLocalizedString("scheduleTable.title",
                           comment: "Text displayed on scheduleTable"),
         nil)]
    
    private let maxLength = 38
    
    private var selectedCategoryString: String?
    
    private let emojies = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    
    private let colors = [
        UIColor.colorSection1,
        UIColor.colorSection2,
        UIColor.colorSection3,
        UIColor.colorSection4,
        UIColor.colorSection5,
        UIColor.colorSection6,
        UIColor.colorSection7,
        UIColor.colorSection8,
        UIColor.colorSection9,
        UIColor.colorSection10,
        UIColor.colorSection11,
        UIColor.colorSection12,
        UIColor.colorSection13,
        UIColor.colorSection14,
        UIColor.colorSection15,
        UIColor.colorSection16,
        UIColor.colorSection17,
        UIColor.colorSection18
    ]

    private var selectedDays: [WeekDay] = []
    
    private let dayCountLabel: UILabel = {
        let dayCountLabel = UILabel()
        dayCountLabel.font = .systemFont(ofSize: 32, weight: .bold)
        dayCountLabel.textColor = UIColor.designBlack
        dayCountLabel.textAlignment = .center
        dayCountLabel.translatesAutoresizingMaskIntoConstraints = false
        return dayCountLabel
    }()
    
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
        textField.placeholder = NSLocalizedString("nameTrackerTextField.title",
                                                  comment: "Text displayed on nameTrackerTextFieldTitle")
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
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.layer.masksToBounds = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let params = GeometricParams(cellCount: 6,
                                         leftInset: 17,
                                         rightInset: 17,
                                         cellSpacing: 5)
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
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
    
    private let cancelButtonTitle = NSLocalizedString("cancelButton.title",
                              comment: "Text displayed on cancelButtonTitle")
    
    private let creationButtonTitle = NSLocalizedString("creationButton.title",
                              comment: "Text displayed on creationButtonTitle")
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        
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
    
    private lazy var creationButton: UIButton = {
        let creationButton = UIButton(type: .system)
        creationButton.setTitle(creationButtonTitle, for: .normal)
        
        creationButton.titleLabel?.tintColor = .designWhite
        creationButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        creationButton.backgroundColor = .designGray
        creationButton.layer.cornerRadius = 16
        creationButton.isEnabled = true
        creationButton.setTitleColor(.designWhite, for: .normal)
        creationButton.setTitleColor(.designWhite, for: .disabled)
        creationButton.addTarget(
            self,
            action: #selector(creationButtonTapped),
            for: .touchUpInside)
        creationButton.translatesAutoresizingMaskIntoConstraints = false
        return creationButton
    }()
    
    init(tracker: Tracker) {
        self.tracker = tracker
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .designWhite
        title = NSLocalizedString("editTrackerVC.title",
                                  comment: "Text displayed on editTrackerVC")
        setupViews()
        insertTrackerData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addLowerBorder(to: tableView)
    }

    // MARK: - Private Methods
    
    private func addLowerBorder(to view: UIView) {
        let borderLowerView = UIView(frame: CGRect(x: 0, y: view.frame.height - 1, width: view.frame.size.width, height: 1.0))
        borderLowerView.backgroundColor = .designWhite
        view.addSubview(borderLowerView)
    }
    
    private func setupViews() {
        view.addSubview(dayCountLabel)
        view.addSubview(stackView)
        view.addSubview(collectionView)
        view.addSubview(stackViewH)
        
        NSLayoutConstraint.activate([
            dayCountLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            dayCountLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            dayCountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: dayCountLabel.bottomAnchor, constant: 40),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField.heightAnchor.constraint(equalToConstant: 75),
            tableView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            stackViewH.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackViewH.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackViewH.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackViewH.heightAnchor.constraint(equalToConstant: 60),
            
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: stackViewH.topAnchor, constant:  -16),
        ])
        
        let completedDays = countTrackerCompletedToday(id: tracker.trackerId)
        dayCountLabel.text = String.localizedStringWithFormat(
            NSLocalizedString(
                "numberOfTasks",
                comment: "Number of daone trackers"),
            completedDays
        )
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HabitTableViewCell.self, forCellReuseIdentifier: "cell")
        textField.delegate = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ColorEmojiCollectionViewCell.self, forCellWithReuseIdentifier: "emojiCellCV")
        collectionView.register(SupplementaryColorEmojiView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "emojiHeader")
        
        collectionView.register(ColorEmojiCollectionViewCell.self, forCellWithReuseIdentifier: "colorCellCV")
        collectionView.register(SupplementaryColorEmojiView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "colorHeader")
        
    }

    private func showCategoryScreen() {
        textField.resignFirstResponder()
        let viewModel = CategoryManagementViewModel(trackerCategoryStore: categoryStore)
        let categoryManagementVC = CategoryManagementViewController(viewModel: viewModel)
        categoryManagementVC.categorySelectionDelegate = self
        let categoryManagementNC = UINavigationController(rootViewController: categoryManagementVC)
        present(categoryManagementNC, animated: true, completion: nil)
    }
    
    private func showScheduleScreen() {
        textField.resignFirstResponder()
        let scheduleVC = ScheduleViewController()
        scheduleVC.scheduleDelegate = self
        let scheduleNC = UINavigationController(rootViewController: scheduleVC)
        present(scheduleNC, animated: true, completion: nil)
    }
    
    private func countTrackerCompletedToday(id: UUID) -> Int {
        var trackerID = 0
        do {
            let count = try trackerRecordStore.countTrackerRecords(forTrackerId: id)
            trackerID = count
            print("Количество записей для трекера с ID: \(count)")
        } catch {
            print("Ошибка при получении количества записей для трекера: \(error)")
        }
        return trackerID
    }
    
    private func insertTrackerData() {
        // Установка значений из существующего трекера
        textField.text = tracker.trackerName
        
        selectedCategoryString = tracker.category
        words[0].subtitle = selectedCategoryString
        
        let scheduleSubtitle: String
        if tracker.trackerSchedule.trackerScheduleDaysOfWeek.isEmpty {
            scheduleSubtitle = NSLocalizedString("scheduleEveryDay.title",
                                                 comment: "Text displayed on scheduleEveryDayTitle")
        } else {
            let shortDayNames = tracker.trackerSchedule.trackerScheduleDaysOfWeek.map { $0.localizedShortString() }
            if shortDayNames.count == 7 {
                scheduleSubtitle = NSLocalizedString("scheduleEveryDay.title",
                                                   comment: "Text displayed on scheduleEveryDayTitle")
            } else {
                scheduleSubtitle = shortDayNames.joined(separator: ", ")
            }
            selectedDays = tracker.trackerSchedule.trackerScheduleDaysOfWeek

        }
        words[1].subtitle = scheduleSubtitle
        
        tableView.reloadData()
        
        let indexEmoji = emojies.firstIndex { emoji in
            tracker.trackerEmoji == emoji
        }

        if let indexEmoji = emojies.firstIndex(where: { tracker.trackerEmoji == $0 }) {
            let indexColors = colors.firstIndex { color in
                guard let trackerCGColor = tracker.trackerColor.cgColor.components,
                      let colorCGColor = color.cgColor.components else {
                    return false
                }

                // Сравнение RGBA компонентов цветов с заданной точностью
                let epsilon: CGFloat = 0.01 // желаемая точность
                return zip(trackerCGColor, colorCGColor).allSatisfy { abs($0 - $1) < epsilon }
            }
            
            if let indexColors = indexColors {
                selectedIndexes = [indexEmoji : indexColors]
                selectedEmoji = emojies[indexEmoji]
                selectedColor = colors[indexColors]
                print("\(indexEmoji) & \(indexColors) & \(selectedIndexes)")
            }
        }
//        updateSelectedCellsInCollectionView()
        updateCreationButtonColor()
    }
    
    func updateSelectedCellsInCollectionView() {
        collectionView.reloadData()
//         Обновляем выбранные ячейки в соответствии с selectedIndexes
        for (section, row) in selectedIndexes {
            let indexPath = IndexPath(row: row, section: section)
            print("&Updated indexPath: \(collectionView(collectionView, cellForItemAt: indexPath)) \(indexPath) \(indexPath.section)")
            if let cell = collectionView(collectionView, cellForItemAt: indexPath) as? ColorEmojiCollectionViewCell {
                if section == 0 {
                    selectedEmoji = emojies[indexPath.row]
                    cell.configureColor(.designLightGray)
                    print("&Updated emoji cell at indexPath: \(indexPath)")
                } else {
                    selectedColor = colors[indexPath.row]
                    cell.pickConfiguredColor(selectedColor ?? .colorSection1)
                    print("&Updated color cell at indexPath: \(indexPath)")
                }
            }
        }
//        updateCreationButtonColor()
    }
    
    @objc private func cancelButtonTapped() {
        textField.resignFirstResponder()
        dismiss(animated: true)
    }
    
    @objc private func creationButtonTapped() {

        if let trackerName = textField.text,
           !trackerName.isEmpty,
           let selectedEmoji = selectedEmoji,
           let selectedColor = selectedColor,
           let selectedCategoryString = selectedCategoryString,
           !selectedDays.isEmpty
        {
            
            creationButton.isEnabled = true
            creationButton.backgroundColor = .designBlack
            
            // Изменение трекера с полными данными
            let updatedTracker = Tracker(
                trackerId: tracker.trackerId,
                trackerName: trackerName,
                trackerColor: selectedColor,
                trackerEmoji: selectedEmoji,
                trackerSchedule: TrackerSchedule(
                    trackerScheduleDaysOfWeek: selectedDays),
                category: selectedCategoryString,
                isDone: tracker.isDone,
                isPinned: tracker.isPinned
            )
            
            delegate?.didUpdateEditedTracker(updatedTracker)
            delegate?.editTrackerVCDismissed(self)
            
        } else {
            creationButton.isEnabled = false
            creationButton.backgroundColor = .designGray
        }
    }
}

// MARK: - UITableViewDataSource

extension EditTrackerViewController: UITableViewDataSource {
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
        let cellInfo = words[indexPath.section]
        
        cell.textLabel?.text = cellInfo.title
        cell.textLabel?.numberOfLines = 1
        
        if let subtitle = cellInfo.subtitle, !subtitle.isEmpty {
            let attributedText = NSMutableAttributedString(string: cellInfo.title, attributes: [
                .foregroundColor: UIColor.designBlack,
                .font: UIFont.systemFont(ofSize: 16, weight: .regular)
            ])
            
            attributedText.append(NSAttributedString(string: "\n\(subtitle)", attributes: [
                .foregroundColor: UIColor.designGray,
                .font: UIFont.systemFont(ofSize: 16, weight: .regular)
            ]))
            
            cell.textLabel?.attributedText = attributedText
            
            cell.textLabel?.numberOfLines = 0
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension EditTrackerViewController: UITableViewDelegate {
    
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

extension EditTrackerViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = .designBlack
        updateCreationButtonColor()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func updateCreationButtonColor() {
            creationButton.isEnabled = true
            creationButton.backgroundColor = .designBlack
    }
}

// MARK: - CategorySelectionDelegate

extension EditTrackerViewController: CategorySelectionDelegate {
    
    func didSelectCategory(_ category: TrackerCategory) {
        selectedCategoryString = category.title
        words[0].subtitle = selectedCategoryString
        tableView.reloadData()
        
        updateCreationButtonColor()
    }
    
    func categoryManagementVCDismissed(_ vc: CategoryManagementViewController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - ScheduleSelectionDelegate

extension EditTrackerViewController: ScheduleSelectionDelegate {
    func didSelectDays(_ days: [WeekDay]) {
        selectedDays = days
        let shortDayNames = days.map { $0.localizedShortString() }
        
        if days.count == 7 {
            words[1].subtitle = NSLocalizedString("scheduleEveryDay.title",
                                                  comment: "Text displayed on scheduleEveryDayTitle")
        } else {
            words[1].subtitle = shortDayNames.joined(separator: ", ")
        }
        tableView.reloadData()
        
        updateCreationButtonColor()
    }
    
    func scheduleVCDismissed(_ vc: ScheduleViewController) {
        dismiss(animated: true, completion: nil)
    }
}
// MARK: - UICollectionViewDataSource

extension EditTrackerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionView == self.collectionView ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return section == 0 ? emojies.count : colors.count
        }
        return section
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Создать ячейку
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: collectionView == self.collectionView ? "emojiCellCV" : "colorCellCV",
            for: indexPath
        ) as? ColorEmojiCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        // Настроить ячейку
        cell.prepareForReuse()
        if collectionView == self.collectionView {
            if indexPath.section == 0 {
                cell.configureColor(.clear)
                cell.configure(title: emojies[indexPath.row])
            } else {
                let color = colors[indexPath.row]
                cell.configureColor(color)
                cell.configure(title: "")
            }
        }
        
        // Возвратить ячейку
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = collectionView == self.collectionView ? "emojiHeader" : "colorHeader"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SupplementaryColorEmojiView
        if collectionView == self.collectionView {
            let colorsHeader = NSLocalizedString("colorsHeaderCV.title",
                                  comment: "Text displayed on colorsHeader")
            if kind == UICollectionView.elementKindSectionHeader {
                view.titleLabel.text = indexPath.section == 0 ? "Emoji" : colorsHeader
            }
        }
        
        return view
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension EditTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(
            collectionView,
            viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
            at: indexPath
        )
        
        return headerView.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width,
                   height: UIView.layoutFittingExpandedSize.height
                  ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: params.leftInset, bottom: 24, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
}

// MARK: - NewHabitCreationViewController

extension EditTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ColorEmojiCollectionViewCell else {
            return
        }
        
        // Проверка, был ли уже выбран элемент в данной секции
        if let selectedRow = selectedIndexes[indexPath.section] {
            // Снятие выделения с предыдущего выбранного элемента
            let previousIndexPath = IndexPath(row: selectedRow, section: indexPath.section)
            if let previousCell = collectionView.cellForItem(at: previousIndexPath) as? ColorEmojiCollectionViewCell {
                if indexPath.section == 0 {
                    previousCell.configureColor(.clear)
                } else {
                    let color = colors[selectedRow]
                    previousCell.configureColor(color)
                }
            }
        }
        
        // Обновление словаря с выбранным индексом в данной секции
        selectedIndexes[indexPath.section] = indexPath.row
        
        if indexPath.section == 0 {
            selectedEmoji = emojies[indexPath.row]
            cell.configureColor(.designLightGray)
        } else {
            selectedColor = colors[indexPath.row]
            cell.pickConfiguredColor(selectedColor ?? .designBackground)
        }
        
        updateCreationButtonColor()
    }
}
