//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Анастасия on 31.01.2024.
//

import Foundation
import CoreData
import UIKit

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    func addTracker(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        updateExistingTracker(trackerRecordCoreData, with: trackerRecord)
        try context.save()
    }
    
    func updateExistingTracker(_ trackerRecordCoreData: TrackerRecordCoreData, with trackerRecord: TrackerRecord) {
        trackerRecordCoreData.date = trackerRecord.date
    }
}

extension TrackerRecordStore {
    func fetchAllTrackerRecords() -> [TrackerRecord] {
        do {
            let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
            let trackerRecordsCoreData = try context.fetch(request)
            return trackerRecordsCoreData.map { coreDataObject in
                return TrackerRecord(trackerID: coreDataObject.trackerID ?? UUID(), date: coreDataObject.date ?? Date())
            }
        } catch {
            print("Failed to fetch tracker records: \(error)")
            return []
        }
    }
    
    func deleteTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(format: "trackerID == %@ AND date == %@", trackerRecord.trackerID as CVarArg, trackerRecord.date as CVarArg)
        
        do {
            let trackerRecordsCoreData = try context.fetch(request)
            if let firstTrackerRecordCoreData = trackerRecordsCoreData.first {
                context.delete(firstTrackerRecordCoreData)
                try context.save()
            }
        } catch {
            throw error
        }
    }
}
