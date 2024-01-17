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
    let trackerEmoji: String?
    let trackerSchedule: TrackerSchedule
    var trackerProgress: Int
    
    init(trackerId: Int, trackerName: String, trackerColor: UIColor, trackerEmoji: String?, trackerSchedule: TrackerSchedule, trackerProgress: Int) {
        self.trackerId = trackerId
        self.trackerName = trackerName
        self.trackerColor = trackerColor
        self.trackerEmoji = trackerEmoji
        self.trackerSchedule = trackerSchedule
        self.trackerProgress = trackerProgress
    }
}

struct TrackerSchedule {
    let trackerScheduleDaysOfWeek: Set<DayOfWeek>
    let trackerScheduleStartTime: Date
    let trackerScheduleEndTime: Date

}

enum DayOfWeek: String, CaseIterable {
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday
}

extension Tracker {
    func calculateDays() -> Int? {
        let calendar = Calendar.current

        guard let startDate = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: trackerSchedule.trackerScheduleStartTime)),
              let endDate = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: trackerSchedule.trackerScheduleEndTime)) else {
            return nil
        }

        let dateComponents = calendar.dateComponents([.day], from: startDate, to: endDate)
        return dateComponents.day
    }
}
