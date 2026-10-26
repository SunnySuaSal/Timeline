//
//  TimelineEvent.swift
//  Timeline
//
//  Created by Sunny Suárez Saldaña on 22/10/26.
//

import Foundation
import SwiftData

@Model
final class TimelineEvent {

    var title: String
    var date: Date
    var notes: String?
    var timeline: Timeline?

    // Nil represents the original day-level precision.
    var datePrecisionRaw: String?

    init(
        title: String,
        date: Date,
        notes: String? = nil,
        precision: EventDatePrecision = .day
    ) {
        self.title = title
        self.date = date
        self.notes = notes
        self.datePrecisionRaw = precision.rawValue
    }
}

// MARK: - Date Precision

extension TimelineEvent {

    var datePrecision: EventDatePrecision {

        get {
            guard let datePrecisionRaw,
                  let precision = EventDatePrecision(
                    rawValue: datePrecisionRaw
                  ) else {
                return .day
            }

            return precision
        }

        set {
            datePrecisionRaw = newValue.rawValue
        }
    }
}
