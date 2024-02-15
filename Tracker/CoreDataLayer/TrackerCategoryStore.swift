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

    func fetchAllCategories() -> [TrackerCategory] {
        do {
            let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
            let categoriesCoreData = try context.fetch(request)
            
            return categoriesCoreData.map { coreDataObject in
                return TrackerCategory(title: coreDataObject.title ?? "", trackers: [])
            }
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }

    func deleteTracker(_ category: TrackerCategory) throws {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "title == %@", category.title)
        
        do {
            let categoriesCoreData = try context.fetch(request)
            if let firstCategoryCoreData = categoriesCoreData.first {
                context.delete(firstCategoryCoreData)
                try context.save()
            }
        } catch {
            throw error
        }
    }

}
