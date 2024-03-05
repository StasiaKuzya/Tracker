//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Анастасия on 04.01.2024.
//

import Foundation
import UIKit

final class StatisticsViewController: UIViewController {
    
    // MARK: -  Properties & Constants
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private var trackers: [Tracker] = []
    var completedTrackers: [TrackerRecord] = []
    
    private lazy var emptyStatStateStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emptyStatStateImage, emptyStatStateLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let emptyStatStateImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "StatEmptyImage")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStatStateLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statEmptyState.title",
                                       comment: "Text displayed on emptyStatState, stat scene")
        label.textAlignment = .center
        label.textColor = .designBlack
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let params = GeometricParams(cellCount: 1,
                                 leftInset: 16,
                                 rightInset: 16,
                                 cellSpacing: 12)
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Методы, которые обновляют данные статистики
        updateStat()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addNCViews()
        setupViews()
//        updateStat()
    }

    // MARK: -  Private Methods
    
    private func addTBViews() {
        if let tabBarController = tabBarController {
            additionalSafeAreaInsets.bottom = tabBarController.tabBar.frame.size.height
        }
    }
    
    private func addNCViews() {
        if let navigationController = navigationController {
            
            navigationController.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .always
            title = NSLocalizedString("statLargeTitle.title",
                                      comment: "Text displayed on statLargeTitle, stat scene")
            navigationController.navigationBar.largeTitleTextAttributes = [
                .foregroundColor: UIColor.designBlack,
                .font: UIFont.systemFont(ofSize: 34, weight: .bold)
            ]
        }
    }
    
    private func setupViews() {
        view.addSubview(collectionView)
        view.addSubview(emptyStatStateStackView)
        
        NSLayoutConstraint.activate([
            
            emptyStatStateStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            emptyStatStateStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            emptyStatStateStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyStatStateStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(StatisticsCollectionViewCell.self, forCellWithReuseIdentifier: "cellStatisticsVC")
    }
    
    private func updateUI() {
        collectionView.reloadData()
        if trackers.isEmpty {
            emptyStatStateStackView.isHidden = false
            collectionView.isHidden = true
        } else {
            emptyStatStateStackView.isHidden = true
            collectionView.isHidden = false
        }
    }
    private func updateStat() {
        trackers = try! trackerStore.fetchTrackers()
        completedTrackers = trackerRecordStore.fetchAllTrackerRecords()
        updateUI()
    }
}

// MARK: - UICollectionViewDataSource

extension StatisticsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Создать ячейку
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellStatisticsVC", for: indexPath) as? StatisticsCollectionViewCell else { return UICollectionViewCell() }
        
        // Настройка ячейки в зависимости от индекса
        switch indexPath.item {
            // Самое большое кол-во дней выполнения у одного трекера
        case 0:
            let maxPeriodData = CellStatData(
                title:  NSLocalizedString("statInfo0.title",
                                          comment: "Text displayed on statInfo0, stat scene"),
                value: statInfo0())
            cell.configure(with: maxPeriodData)
            // Максимальное колво выполненных трекеров в 1 день
        case 1:
            let allTrackersCompletedData = CellStatData(
                title: NSLocalizedString("statInfo1.title",
                                         comment: "Text displayed on statInfo1, stat scene"),
                value: statInfo1())
            cell.configure(with: allTrackersCompletedData)
            // Всего выполненных трекеров
        case 2:
            let maxTrackersPerDayData = CellStatData(
                title: NSLocalizedString("statInfo2.title",
                                         comment: "Text displayed on statInfo2, stat scene"),
                value: completedTrackers.count)
            cell.configure(with: maxTrackersPerDayData)
            // Среднее кол-во выполненных трекеров в день
        case 3:
            let averageTrackersPerDayData = CellStatData(
                title: NSLocalizedString("statInfo3.title",
                                         comment: "Text displayed on statInfo3, stat scene"),
                value: statInfo3())
            cell.configure(with: averageTrackersPerDayData)
        default:
            break
        }
        
        // Возвратить ячейку
        return cell
    }
    
    private func statInfo0() -> Int {
        let allIDs = Set(completedTrackers.map { $0.trackerID })
        var countID: [UUID: Int] = [:]
        for id in allIDs {
            let trackers = completedTrackers.filter { $0.trackerID == id }.count
            countID[id] = trackers
        }
        let result = countID.values.max() ?? 0
        return result
    }
    
    private func statInfo1() -> Int {
        let allIDs = Set(completedTrackers.map { $0.date })
        var countID: [Date: Int] = [:]
        for date in allIDs {
            let trackers = completedTrackers.filter { $0.date == date }.count
            countID[date] = trackers
        }
        let result = countID.values.max() ?? 0
        return result
    }
    private func statInfo3() -> Int {
        let uniqueDaysWithTrackers = Set(completedTrackers.map { $0.date }).count
        var averageTrackersPerDay = 0
        if uniqueDaysWithTrackers == 0 {
            averageTrackersPerDay = 0
        } else {
            averageTrackersPerDay = completedTrackers.count / uniqueDaysWithTrackers
        }
        return averageTrackersPerDay
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension StatisticsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 70, left: params.leftInset, bottom: 0, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
}

// MARK: - UICollectionViewDelegate
