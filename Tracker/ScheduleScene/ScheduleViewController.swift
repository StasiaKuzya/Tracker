//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Анастасия on 14.01.2024.
//

import Foundation
import UIKit

protocol ScheduleSelectionDelegate: AnyObject {
    func didSelectDays(_ days: [WeekDay])
    func scheduleVCDismissed(_ vc: ScheduleViewController)
}

final class ScheduleViewController: UIViewController {
    
    // MARK: -  Properties & Constants
    
    weak var scheduleDelegate: ScheduleSelectionDelegate?
    
//    private let daysOfWeek: [String] = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
//    private let shortDaysOfWeek: [String] = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    private var daysOfWeek: [WeekDay] = []
    private var shortDaysOfWeek: [String] = []

    
    private var selectedDays: [WeekDay] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: "scheduleCell")
        return tableView
    }()
    
    private let saveButton: UIButton = {
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Готово", for: .normal)
        saveButton.isEnabled = false
        saveButton.titleLabel?.tintColor = .designWhite
        saveButton.setTitleColor(.designWhite, for: .normal)
        saveButton.setTitleColor(.designWhite, for: .disabled)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        saveButton.backgroundColor = .designGray
        saveButton.layer.cornerRadius = 16
        saveButton.addTarget(
            self,
            action: #selector(saveButtonTapped),
            for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        return saveButton
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Расписание"
        view.backgroundColor = .white
        
        setDaysOfWeek()
        
        setupViews()
    }
    
    // MARK: - Private Methods
    
    private func setDaysOfWeek() {
        daysOfWeek = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        shortDaysOfWeek = daysOfWeek.map { $0.shortName }
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(saveButton)
        
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = view.backgroundColor?.cgColor
        
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        tableView.rowHeight = 75
        let tableCount : CGFloat = CGFloat(daysOfWeek.count)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: tableView.rowHeight * tableCount),
            
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            saveButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc private func saveButtonTapped() {
        scheduleDelegate?.didSelectDays(selectedDays)
        scheduleDelegate?.scheduleVCDismissed(self)
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath) as? ScheduleTableViewCell else {
            fatalError("Unable to dequeue ScheduleTableViewCell")
        }

        let day = daysOfWeek[indexPath.row]
        let shortDay = shortDaysOfWeek[indexPath.row]

        cell.selectionStyle = .none
        cell.configure(title: day.rawValue)
        cell.switchControl.isOn = selectedDays.contains(day)
        cell.switchControl.tag = indexPath.row

        updateSaveButtonState()
        return cell
    }

    @objc func switchChanged(_ sender: UISwitch) {
//        let selectedDay = shortDaysOfWeek[sender.tag]
        let selectedDay = daysOfWeek[sender.tag]
//        guard let weekDay = WeekDay(rawValue: selectedDay) else { return }

        if sender.isOn {
            selectedDays.append(selectedDay)
        } else {
            selectedDays.removeAll { $0 == selectedDay }
        }
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ScheduleTableViewCell {
            cell.switchControl.setOn(!cell.switchControl.isOn, animated: true)
            switchChanged(cell.switchControl)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
        updateSaveButtonState()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    private func updateSaveButtonState() {
        if selectedDays.isEmpty {
            saveButton.backgroundColor = .designGray
            saveButton.isEnabled = false
        } else {
            saveButton.backgroundColor = .designBlack
            saveButton.isEnabled = true
        }
    }
}
