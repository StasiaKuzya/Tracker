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
    private let trackerStore = TrackerStore()
    
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
        
        // Получение связанного трекера из TrackerStore
        guard let trackerCoreData = try? trackerStore.fetchTrackerByIdForRecords(trackerRecord.trackerID) else {
            throw NSError(domain: "TrackerRecordStore",
                          code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to fetch associated Tracker"])
        }
        trackerRecordCoreData.trackerCoreData = trackerCoreData
        
        try context.save()
    }

    func updateExistingTracker(_ trackerRecordCoreData: TrackerRecordCoreData, with trackerRecord: TrackerRecord) {
        trackerRecordCoreData.trackerID = trackerRecord.trackerID
        trackerRecordCoreData.date = trackerRecord.date
    }
}

extension TrackerRecordStore {
    func fetchAllTrackerRecords() -> [TrackerRecord] {
        do {
            let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
            let trackerRecordsCoreData = try context.fetch(request)
            return trackerRecordsCoreData.map { coreDataObject in
                return TrackerRecord(
                    trackerID: coreDataObject.trackerID ?? UUID(),
                    date: coreDataObject.date ?? Date()
                )
            }
        } catch {
            print("Failed to fetch tracker records: \(error)")
            return []
        }
    }
    
    func deleteTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(
            format: "trackerID == %@ AND date == %@",
            trackerRecord.trackerID as CVarArg,
            trackerRecord.date as CVarArg)
        
        do {
            let trackerRecordsCoreData = try context.fetch(request)
            if let firstTrackerRecordCoreData = trackerRecordsCoreData.first {
                context.delete(firstTrackerRecordCoreData)
                try context.save()
            }
        } catch {
            print("Failed to delete tracker record: \(error)")
            throw error
        }
    }
    
    func deleteTrackerRecordsForOne(by trackerId: UUID) {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(format: "trackerID == %@", trackerId as CVarArg)
        
        do {
            let trackerRecordsCoreData = try context.fetch(request)
            for trackerRecord in trackerRecordsCoreData {
                context.delete(trackerRecord)
            }
            try context.save()
        } catch {
            print("Failed to delete tracker records: \(error)")
        }
    }
    
    func countTrackerRecords(forTrackerId trackerId: UUID) throws -> Int {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerID == %@", trackerId as CVarArg)
        do {
             let count = try context.count(for: fetchRequest)
             return count
         } catch {
             throw error
         }
    }
}
