//
//  TrackerStore.swift
//  Tracker
//
//  Created by Анастасия on 31.01.2024.
//

import Foundation
import CoreData
import UIKit

enum TrackerStoreError: Error {
    case decodingErrorInvalidId
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private var categories: [TrackerCategoryCoreData] = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category", ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience override init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    func addTracker(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTracker(trackerCoreData, with: tracker)
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.trackerId = tracker.trackerId
        trackerCoreData.trackerName = tracker.trackerName
        trackerCoreData.trackerColor = tracker.trackerColor.toHex()
        trackerCoreData.trackerEmoji = tracker.trackerEmoji
        
        let encoder = JSONEncoder()
        if let encodedSchedule = try? encoder.encode(tracker.trackerSchedule) {
            trackerCoreData.trackerSchedule = encodedSchedule
        }
        
        do {
            if let category = try fetchCategoryByName(tracker.category) {
                trackerCoreData.trackerCategoryCoreData = category
            } else {
                let newCategory = createCategory(title: tracker.category)
                trackerCoreData.trackerCategoryCoreData = newCategory
                newCategory.title = tracker.category
            }
        } catch {
            print("Error fetching category: \(error)")
        }
        trackerCoreData.category = trackerCoreData.trackerCategoryCoreData?.title
        
        trackerCoreData.isDone = ((trackerCoreData.trackerRecordCoreDate?.contains(tracker.trackerId)) != nil)
    }
    
    func createCategory(title: String) -> TrackerCategoryCoreData {
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = title
        return newCategory
    }
    
    func fetchCategoryByName(_ categoryName: String) throws -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", categoryName)
        
        return try context.fetch(fetchRequest).first
    }
    
    func fetchTrackerByIdForRecords(_ trackerId: UUID) throws -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        
        return try context.fetch(fetchRequest).first
    }
}

extension TrackerStore {
    
    func fetchTrackers() throws -> [Tracker] {

        let fetchRequest = TrackerCoreData.fetchRequest()
        let trackerCoreData = try context.fetch(fetchRequest)

        // Обновление категории при каждом запросе трекеров
        categories = try context.fetch(TrackerCategoryCoreData.fetchRequest())
        return try trackerCoreData.map { try self.tracker(from: $0) }
    }

    func tracker(from trackerCorData: TrackerCoreData) throws -> Tracker {
        guard let trackerId = trackerCorData.trackerId else {
            throw TrackerStoreError.decodingErrorInvalidId
        }
        
        let trackerName = trackerCorData.trackerName ?? ""
        let trackerColorHex = trackerCorData.trackerColor ?? "#FFFFFF"
        let trackerEmoji = trackerCorData.trackerEmoji ?? ""
        
        var trackerSchedule: TrackerSchedule
        if let scheduleData = trackerCorData.trackerSchedule {
            trackerSchedule = try JSONDecoder().decode(TrackerSchedule.self, from: scheduleData)
        } else {
            trackerSchedule = TrackerSchedule(trackerScheduleDaysOfWeek: [])
        }
        
        let category = trackerCorData.category ?? ""
        
        // Проверка наличия трекера в записях
        let isDone = trackerCorData.trackerRecordCoreDate?.contains(trackerId) == true
        
        return Tracker(
            trackerId: trackerId,
            trackerName: trackerName,
            trackerColor: UIColor(hexString: trackerColorHex) ?? .designBlue,
            trackerEmoji: trackerEmoji,
            trackerSchedule: trackerSchedule,
            category: category,
            isDone: isDone
        )
    }
}
