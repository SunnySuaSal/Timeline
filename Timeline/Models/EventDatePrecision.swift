//
//  EventDatePrecision.swift
//  Timeline
//
//  Created by Sunny Suárez Saldaña on 26/10/26.
//

import Foundation

enum EventDatePrecision: String, CaseIterable, Identifiable {

    case year
    case month
    case day

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .year:
            return "Year"
        case .month:
            return "Month"
        case .day:
            return "Day"
        }
    }
}
