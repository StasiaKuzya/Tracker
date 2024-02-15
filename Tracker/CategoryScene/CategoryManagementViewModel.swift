//
//  CategoryManagementViewModel.swift
//  Tracker
//
//  Created by Анастасия on 14.02.2024.
//

import Foundation

class CategoryManagementViewModel {

    var reloadTableViewClosure: (() -> ())?
    var categories: [TrackerCategory] = [] {
        didSet {
            reloadTableViewClosure?()
        }
    }
    private let trackerCategoryStore: TrackerCategoryStore
    
    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
    }
    
    func addCategoryToCD(category: TrackerCategory) {
        do {
            try trackerCategoryStore.addTracker(category)
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
    
    func fetchCategories() {
        categories = trackerCategoryStore.fetchAllCategories()
    }
    
    func didSelectCategory(at index: Int) {
        // Обработка выбранной категории
    }
}
