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
