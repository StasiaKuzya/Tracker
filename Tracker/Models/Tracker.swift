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
    let isDone: Bool
    
    init(trackerId: UUID, trackerName: String, trackerColor: UIColor, trackerEmoji: String, trackerSchedule: TrackerSchedule, category: String, isDone: Bool) {
        self.trackerId = trackerId
        self.trackerName = trackerName
        self.trackerColor = trackerColor
        self.trackerEmoji = trackerEmoji
        self.trackerSchedule = trackerSchedule
        self.category = category
        self.isDone = isDone
    }
}

struct TrackerSchedule: Codable {
    let trackerScheduleDaysOfWeek: [WeekDay]
}

enum WeekDay: String, Codable {
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
    
    var numberDay: Int {
        switch self {
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        case .sunday: return 1
        }
    }
}

extension WeekDay {
    func convertToData() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self.rawValue)
    }

    static func convertFromData(data: Data) throws -> WeekDay {
        let decoder = JSONDecoder()
        let rawValue = try decoder.decode(String.self, from: data)
        guard let day = WeekDay(rawValue: rawValue) else {
            throw NSError(domain: "Invalid WeekDay raw value", code: 0, userInfo: nil)
        }
        return day
    }
    
    func localizedString() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
    
    func localizedShortString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols[numberDay - 1]
    }
}
