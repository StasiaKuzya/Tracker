//
//  CategoryManagementViewModel.swift
//  Tracker
//
//  Created by Анастасия on 14.02.2024.
//

import Foundation

typealias CategoryBinding = ([TrackerCategory]) -> Void
typealias ErrorBinding = (Error) -> Void

class CategoryManagementViewModel {

    var onCategoriesChange: CategoryBinding?
    var onError: ErrorBinding?
    
    var didSelectCategoryClosure: ((TrackerCategory) -> Void)?
    var categoryManagementVCDimissedClosure: (() -> Void)?

    var categories: [TrackerCategory] = []

    private let trackerCategoryStore: TrackerCategoryStore
    
    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
    }
    
    func addCategoryToCD(category: TrackerCategory) {
        do {
            try trackerCategoryStore.addTracker(category)
            fetchCategories()
        } catch {
            onError?(error)
        }
    }
    
    func fetchCategories() {
        let fetchedCategories = trackerCategoryStore.fetchAllCategories()
        categories = fetchedCategories
        onCategoriesChange?(categories)

    }
    
    func didSelectCategory(at index: Int) {
        let selectedCategory = categories[index]
        didSelectCategoryClosure?(selectedCategory)
        categoryManagementVCDimissedClosure?()
    }
}
