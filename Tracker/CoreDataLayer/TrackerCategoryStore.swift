//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Анастасия on 31.01.2024.
//

import Foundation
import CoreData
import UIKit

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    func addTracker(_ category: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        updateExistingTracker(trackerCategoryCoreData, with: category)
        try context.save()
    }
    
    func updateExistingTracker(_ trackerCategoryCoreData: TrackerCategoryCoreData, with category: TrackerCategory) {
        trackerCategoryCoreData.title = category.title
    }
}
