//
//  TrackerFilterOption.swift
//  Tracker
//
//  Created by Анастасия on 06.03.2024.
//

import Foundation

enum TrackerFilterOption: String {
    case all
    case today
    case completed
    case incompleted
    
    var name: String {
        switch self {
            case .all: return NSLocalizedString("All", comment: "")
            case .today: return NSLocalizedString("Today", comment: "")
            case .completed: return NSLocalizedString("Completed", comment: "")
            case .incompleted: return NSLocalizedString("Incompleted", comment: "")
        }
    }
}
