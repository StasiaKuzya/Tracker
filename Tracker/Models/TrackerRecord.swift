//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Анастасия on 08.01.2024.
//

import Foundation

struct TrackerRecord {
    let trackerRecordId: UUID
    let trackerID: Int
    let date: Date

    init(trackerID: Int, date: Date) {
        self.trackerRecordId = UUID()
        self.trackerID = trackerID
        self.date = date
    }
}
