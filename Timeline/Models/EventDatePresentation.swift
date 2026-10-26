//
//  EventDatePresentation.swift
//  Timeline
//
//  Created by Sunny Suárez Saldaña on 26/10/26.
//

import Foundation

enum EventDatePresentation {

    static func string(
        for date: Date,
        precision: EventDatePrecision
    ) -> String {

        let formatter = DateFormatter()

        formatter.locale = .current
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current

        switch precision {

        case .year:
            formatter.setLocalizedDateFormatFromTemplate("y")

        case .month:
            formatter.setLocalizedDateFormatFromTemplate("yMMMM")

        case .day:
            formatter.setLocalizedDateFormatFromTemplate("yMMMMd")
        }

        return formatter.string(from: date)
    }
}
