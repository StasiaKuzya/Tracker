//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Анастасия on 14.01.2024.
//

import Foundation
import UIKit

protocol ScheduleSelectionDelegate: AnyObject {
    func didSelectDays(_ days: [String])
}

final class ScheduleViewController: UIViewController {
    
    // MARK: -  Properties & Constants
    
    weak var scheduleDelegate: ScheduleSelectionDelegate?
    
    let daysOfWeek: [String: String] = [
        "Понедельник": "Пн",
        "Вторник": "Вт",
        "Среда": "Ср",
        "Четверг": "Чт",
        "Пятница": "Пт",
        "Суббота": "Сб",
        "Воскресенье": "Вс"
    ]
    private var selectedDays: [String] = []
    
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

        tableView.dataSource = self
        tableView.delegate = self
        
        setupViews()
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(greaterThanOrEqualTo: saveButton.topAnchor, constant: 24),
            
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            saveButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func saveButtonTapped() {
        if selectedDays.count == daysOfWeek.count {
            scheduleDelegate?.didSelectDays(["Каждый день"])
        } else {
            scheduleDelegate?.didSelectDays(selectedDays)
        }
        print("Выбранные дни: \(selectedDays)")
        dismiss(animated: true, completion: nil)
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
        
        cell.selectionStyle = .none
        cell.dayLabel.text = Array(daysOfWeek.keys)[indexPath.row]
        cell.switchControl.isOn = selectedDays.contains(Array(daysOfWeek.keys)[indexPath.row])
        cell.switchControl.tag = indexPath.row
        
        updateSaveButtonState()
        return cell
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        let selectedDay = Array(daysOfWeek.values)[sender.tag]
        
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
        print("selected days \(selectedDays)")
        print("selected days \(selectedDays.isEmpty)")
    }
}