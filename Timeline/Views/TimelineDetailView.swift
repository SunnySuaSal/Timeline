//
//  TimelineDetailView.swift
//  Timeline
//
//  Created by Sunny Suárez Saldaña on 22/10/26.
//



import SwiftUI

struct TimelineDetailView: View {

    let timeline: Timeline

    private var scale: TimelineScale {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let centerDate = calendar.date(
            from: DateComponents(
                year: 1980,
                month: 1,
                day: 1
            )
        )!

        return TimelineScale(
            centerDate: centerDate,
            pointsPerYear: 9
        )
    }

    var body: some View {
        VStack(spacing: 24) {

            Text(timeline.name)
                .font(.largeTitle)
                .bold()

            Text("\(timeline.events.count) events")
                .foregroundStyle(.secondary)

            TimelineAxisView(scale: scale)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .padding()
        .navigationTitle(timeline.name)
    }
}
