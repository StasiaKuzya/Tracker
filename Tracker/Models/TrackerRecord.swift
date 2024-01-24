//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Анастасия on 08.01.2024.
//

import Foundation

struct TrackerRecord {
    let trackerID: UUID
    let date: Date

    init(trackerID: UUID, date: Date) {
        self.trackerID = trackerID
        self.date = date
    }
}
