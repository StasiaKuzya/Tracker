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
    let trackerEmoji: String
    let trackerSchedule: TrackerSchedule
    let category: String
    
    init(trackerId: UUID, trackerName: String, trackerColor: UIColor, trackerEmoji: String, trackerSchedule: TrackerSchedule, category: String) {
        self.trackerId = trackerId
        self.trackerName = trackerName
        self.trackerColor = trackerColor
        self.trackerEmoji = trackerEmoji
        self.trackerSchedule = trackerSchedule
        self.category = category
    }
}

struct TrackerSchedule {
    let trackerScheduleDaysOfWeek: [WeekDay]
}

enum WeekDay: String {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    var shortName: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}
