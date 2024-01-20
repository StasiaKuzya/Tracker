//
//  NewHabitCreationViewController.swift
//  Tracker
//
//  Created by Анастасия on 12.01.2024.
//

import Foundation
import UIKit

protocol TrackerDataDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker)
    func selectedCategory(_ category: String)
    func newHabitCreationVCDismissed(_ vc: NewHabitCreationViewController)
}

final class NewHabitCreationViewController: UIViewController {

    // MARK: -  Properties & Constants
    weak var delegate: TrackerDataDelegate?
    
    private var words: [(title: String, subtitle: String?)] = [("Категория", nil), ("Расписание", nil)]

    private let maxLength = 38
    
    private var selectedCategory: String?
    
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
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.layer.masksToBounds = true
        return tableView
    }()
    
    let params = GeometricParams(cellCount: 6,
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
        
        setupViews()
        tableView.reloadData()
        
        didSelectCategory(selectedCategory ?? "")
        didSelectDays([])
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.addSubview(stackView)
        view.addSubview(collectionView)
        view.addSubview(stackViewH)
        
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = view.backgroundColor?.cgColor
        
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
            stackViewH.heightAnchor.constraint(equalToConstant: 60),
            
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: stackViewH.topAnchor, constant:  -16),
        ])
        
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
        let categoryManagementVC = CategoryManagementViewController()
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

    @objc private func cancelButtonTapped() {
        textField.resignFirstResponder()
        dismiss(animated: true)
    }

    @objc private func creationButtonTapped() {
//        guard let text = textField.text, text.count <= maxLength else {
//            return
//        }
        let daysOfWeek: Set<DayOfWeek> = [.monday, .wednesday, .friday]
        let startTime = Date()
        let endTime = Date().addingTimeInterval(60 * 60 * 2)
        let trackerSchedule = TrackerSchedule(trackerScheduleDaysOfWeek: daysOfWeek,
                                              trackerScheduleStartTime: startTime,
                                              trackerScheduleEndTime: endTime)
        
        guard let trackerName = textField.text, !trackerName.isEmpty else {
            return
        }
        
        // Создание трекера с полными данными
        let tracker = Tracker(
            trackerId: UUID(),
            trackerName: trackerName,
            trackerColor: .colorSection1,
            trackerEmoji: "😪",
            trackerSchedule: trackerSchedule,
            trackerProgress: 0
        )
        
        delegate?.didCreateTracker(tracker)
        delegate?.selectedCategory(selectedCategory ?? "Неназванные категории")
        delegate?.newHabitCreationVCDismissed(self)
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

    // MARK: - CategorySelectionDelegate

extension NewHabitCreationViewController: CategorySelectionDelegate {
    func didSelectCategory(_ category: String) {
        selectedCategory = category
        words[0].subtitle = selectedCategory
        print("categ \(category)")
        tableView.reloadData()
    }
    
    func categoryManagementVCDismissed(_ vc: CategoryManagementViewController) {
        dismiss(animated: true, completion: nil)
    }
}

    // MARK: - ScheduleSelectionDelegate

extension NewHabitCreationViewController: ScheduleSelectionDelegate {
    func didSelectDays(_ days: [String]) {
        words[1].subtitle = days.joined(separator: ", ")
        tableView.reloadData()
    }
    
    func scheduleVCDismissed(_ vc: ScheduleViewController) {
        dismiss(animated: true, completion: nil)
    }
}
    // MARK: - UICollectionViewDataSource

extension NewHabitCreationViewController: UICollectionViewDataSource {
    
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
                cell.titleLabel.text = emojies[indexPath.row]
                cell.configureColor(.clear)
            } else {
                let color = colors[indexPath.row]
                cell.configureColor(color)

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
            if kind == UICollectionView.elementKindSectionHeader {
                view.titleLabel.text = indexPath.section == 0 ? "Emoji" : "Цвета"
            }
        }

        return view
    }
}

    // MARK: - UICollectionViewDelegateFlowLayout

extension NewHabitCreationViewController: UICollectionViewDelegateFlowLayout {
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

extension NewHabitCreationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ColorEmojiCollectionViewCell else {
            return
        }
        
        if indexPath.section == 0 {
            cell.titleLabel.text = emojies[indexPath.row]
            cell.pickConfiguredColor(.designBackground)
        } else {
            let color = colors[indexPath.row]
            cell.pickConfiguredColor(color)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ColorEmojiCollectionViewCell else {
            return
        }
        
        if indexPath.section == 0 {
            cell.titleLabel.text = emojies[indexPath.row]
            cell.configureColor(.clear)
        } else {
            let color = colors[indexPath.row]
            cell.configureColor(color)
        }
    }
}
