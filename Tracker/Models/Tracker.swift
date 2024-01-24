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
    var trackerProgress: Int
    
    init(trackerId: UUID, trackerName: String, trackerColor: UIColor, trackerEmoji: String?, trackerSchedule: TrackerSchedule, trackerProgress: Int) {
        self.trackerId = trackerId
        self.trackerName = trackerName
        self.trackerColor = trackerColor
        self.trackerEmoji = trackerEmoji
        self.trackerSchedule = trackerSchedule
        self.trackerProgress = trackerProgress
    }
}

struct TrackerSchedule {
    let trackerScheduleDaysOfWeek: [String]
}
