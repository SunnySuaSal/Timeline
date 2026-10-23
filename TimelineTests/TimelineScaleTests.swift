//
//  TimelineTests.swift
//  TimelineTests
//
//  Created by Sunny Suárez Saldaña on 23/10/26.
//


import Foundation
import Testing
@testable import Timeline

struct TimelineScaleTests {

    @Test
    func centerDateIsAtViewportCenter() {

        let center = Date.now

        let scale = TimelineScale(
            centerDate: center,
            pointsPerYear: 20
        )

        let position = scale.xPosition(
            for: center,
            viewportWidth: 800
        )

        #expect(position == 400)
    }

    @Test
    func laterDatesAppearToTheRight() {

        let center = Date.now

        let scale = TimelineScale(
            centerDate: center,
            pointsPerYear: 20
        )

        let future = center.addingTimeInterval(86400)

        let position = scale.xPosition(
            for: future,
            viewportWidth: 800
        )

        #expect(position > 400)
    }

    @Test
    func dateConversionIsReversible() {

        let center = Date.now

        let scale = TimelineScale(
            centerDate: center,
            pointsPerYear: 20
        )

        let original = center.addingTimeInterval(86400 * 365)

        let position = scale.xPosition(
            for: original,
            viewportWidth: 800
        )

        let recovered = scale.date(
            at: position,
            viewportWidth: 800
        )

        let difference = abs(
            recovered.timeIntervalSince(original)
        )

        #expect(difference < 0.01)
    }

    @Test
    func increasingScaleIncreasesDistance() {

        let center = Date.now
        let future = center.addingTimeInterval(86400 * 365)

        let small = TimelineScale(
            centerDate: center,
            pointsPerYear: 10
        )

        let large = TimelineScale(
            centerDate: center,
            pointsPerYear: 30
        )

        let first = small.xPosition(
            for: future,
            viewportWidth: 800
        )

        let second = large.xPosition(
            for: future,
            viewportWidth: 800
        )

        #expect(second > first)
    }
}

