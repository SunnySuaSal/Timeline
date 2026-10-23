//
//  TimelineScale.swift
//  Timeline
//
//  Created by Sunny Suárez Saldaña on 23/10/26.
//


import Foundation
import CoreGraphics

struct TimelineScale {

    // MARK: - Properties

    var centerDate: Date
    var pointsPerYear: Double

    // Average length of a Gregorian year in seconds
    private let secondsPerYear = 365.2425 * 24 * 60 * 60

    // MARK: - Date to Position

    func xPosition(
        for date: Date,
        viewportWidth: CGFloat
    ) -> CGFloat {

        let centerX = Double(viewportWidth) / 2

        let elapsedSeconds = date.timeIntervalSince(centerDate)

        let pointsPerSecond = pointsPerYear / secondsPerYear

        let offset = elapsedSeconds * pointsPerSecond

        return CGFloat(centerX + offset)
    }

    // MARK: - Position to Date

    func date(
        at xPosition: CGFloat,
        viewportWidth: CGFloat
    ) -> Date {

        precondition(pointsPerYear > 0)

        let centerX = Double(viewportWidth) / 2

        let offset = Double(xPosition) - centerX

        let pointsPerSecond = pointsPerYear / secondsPerYear

        let elapsedSeconds = offset / pointsPerSecond

        return centerDate.addingTimeInterval(elapsedSeconds)
    }
}
