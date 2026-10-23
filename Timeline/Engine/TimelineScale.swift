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

    static let secondsPerYear = 365.2425 * 24 * 60 * 60

    static let minimumZoom = 2.0
    static let maximumZoom = 200.0

    // MARK: - Coordinate Conversion

    func xPosition(
        for date: Date,
        viewportWidth: CGFloat
    ) -> CGFloat {

        let centerX = Double(viewportWidth) / 2

        let elapsedSeconds = date.timeIntervalSince(centerDate)

        let pointsPerSecond =
            pointsPerYear / Self.secondsPerYear

        return CGFloat(
            centerX + elapsedSeconds * pointsPerSecond
        )
    }

    func date(
        at xPosition: CGFloat,
        viewportWidth: CGFloat
    ) -> Date {

        precondition(pointsPerYear > 0)

        let centerX = Double(viewportWidth) / 2
        let offset = Double(xPosition) - centerX

        let pointsPerSecond =
            pointsPerYear / Self.secondsPerYear

        let elapsedSeconds = offset / pointsPerSecond

        return centerDate.addingTimeInterval(
            elapsedSeconds
        )
    }

    // MARK: - Navigation

    func panned(by translation: CGFloat) -> TimelineScale {

        precondition(pointsPerYear > 0)

        let secondsPerPoint =
            Self.secondsPerYear / pointsPerYear

        let seconds = Double(translation) * secondsPerPoint

        return TimelineScale(
            centerDate: centerDate.addingTimeInterval(
                -seconds
            ),
            pointsPerYear: pointsPerYear
        )
    }

    func zoomed(by factor: CGFloat) -> TimelineScale {

        let newZoom = min(
            max(
                pointsPerYear * Double(factor),
                Self.minimumZoom
            ),
            Self.maximumZoom
        )

        return TimelineScale(
            centerDate: centerDate,
            pointsPerYear: newZoom
        )
    }
}
