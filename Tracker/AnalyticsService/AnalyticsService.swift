//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Анастасия on 08.03.2024.
//

import Foundation
import AppMetricaCore

struct AnalyticsService {
    static func activate() {
        let configuration = AppMetricaConfiguration(apiKey: "c70bbbd6-57e3-4e08-bf0b-6a09cf966189")
        AppMetrica.activate(with: configuration!)
    }
    
    func report(event: String, params: [String: Any]) {
        let params : [AnyHashable : Any] = ["key1": "value1", "key2": "value2"]
        AppMetrica.reportEvent(name: "EVENT", parameters: params, onFailure: { (error) in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
