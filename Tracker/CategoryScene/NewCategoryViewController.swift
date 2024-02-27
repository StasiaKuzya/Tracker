//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Анастасия on 13.01.2024.
//

import Foundation
import UIKit

protocol NewCategoryDelegate: AnyObject {
    func didAddCategory(_ category: TrackerCategory)
    func newCategoryVCDidCancel(_ vc: NewCategoryViewController)
}

final class NewCategoryViewController: UIViewController {
    
    // MARK: -  Properties & Constants
    
    weak var delegate: NewCategoryDelegate?
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("newCategoryTextField.title",
                                                  comment: "Text displayed on newCategoryTextField")
        textField.textColor = .designGray
        textField.backgroundColor = .designBackground
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.layer.cornerRadius = 16
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        textField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let saveCategoryButtonTitle = NSLocalizedString("saveButton.title",
                                      comment: "Text displayed on saveCategoryButtonTitle")
    
    private lazy var saveButton: UIButton = {
        let saveButton = UIButton(type: .system)
        saveButton.setTitle(saveCategoryButtonTitle, for: .normal)
        
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
        title = NSLocalizedString("newCategoryLabelTitle.title",
                                  comment: "Text displayed on newCategoryLabelTitle")
        view.backgroundColor = .white
        
        textField.delegate = self
        setupViews()
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.addSubview(textField)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            saveButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            saveButton.isEnabled = true
            saveButton.backgroundColor = .designBlack
        } else {
            saveButton.isEnabled = false
            saveButton.backgroundColor = .designGray
        }
    }
    
    @objc private func saveButtonTapped() {
        guard let categoryName = textField.text, !categoryName.isEmpty else {
            return
        }
        let newCategory = TrackerCategory(title: categoryName, trackers: [])
        delegate?.didAddCategory(newCategory)
        delegate?.newCategoryVCDidCancel(self)
    }
}

// MARK: - UITextFieldDelegate

extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = .designBlack
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
