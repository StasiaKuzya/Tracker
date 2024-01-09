//
//  Tracker.swift
//  Tracker
//
//  Created by Анастасия on 08.01.2024.
//

import Foundation
import UIKit

struct Tracker {
    let trackerId: Int
    let trackerName: String
    let trackerColor: UIColor
    let trackerEmoji: String
    let trackerSchedule: TrackerSchedule
}

struct TrackerSchedule {
    let trackerScheduleDaysOfWeek: Set<DayOfWeek>
    let trackerScheduleStartTime: Date
    let trackerScheduleEndTime: Date

}

enum DayOfWeek: String, CaseIterable {
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday
}
