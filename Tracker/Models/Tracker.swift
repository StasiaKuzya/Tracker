//
//  Tracker.swift
//  Tracker
//
//  Created by Анастасия on 08.01.2024.
//

import Foundation
import UIKit

struct Tracker {
    let trackerId: UUID
    let trackerName: String
    let trackerColor: UIColor
    let trackerEmoji: String?
    let trackerSchedule: TrackerSchedule
    var creationDate: Date
    
    init(trackerId: UUID, trackerName: String, trackerColor: UIColor, trackerEmoji: String?, trackerSchedule: TrackerSchedule, creationDate: Date) {
        self.trackerId = trackerId
        self.trackerName = trackerName
        self.trackerColor = trackerColor
        self.trackerEmoji = trackerEmoji
        self.trackerSchedule = trackerSchedule
        self.creationDate = creationDate
    }
    
//    private enum CodingKeys: String, CodingKey {
//        case trackerId
//        case trackerName
//        case trackerColor
//        case trackerEmoji
//        case trackerSchedule
//        case creationDate
//    }
}

struct TrackerSchedule: Codable {
    let trackerScheduleDaysOfWeek: [String]
}
