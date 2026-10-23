//
//  TimelineAxisView.swift
//  Timeline
//
//  Created by Sunny Suárez Saldaña on 23/10/26.
//


import SwiftUI

struct TimelineAxisView: View {

    let scale: TimelineScale

    private let years = Array(
        stride(from: 1900, through: 2100, by: 10)
    )

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {

                // Main horizontal axis
                Rectangle()
                    .fill(.secondary)
                    .frame(
                        width: geometry.size.width,
                        height: 6
                    )
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2
                    )

                // Year markers
                ForEach(years, id: \.self) { year in

                    let x = scale.xPosition(
                        for: date(for: year),
                        viewportWidth: geometry.size.width
                    )

                    if x >= 0 && x <= geometry.size.width {

                        VStack(spacing: 8) {
                            Rectangle()
                                .fill(.primary)
                                .frame(width: 2, height: 20)

                            Text(String(year))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .position(
                            x: x,
                            y: geometry.size.height / 2 + 24
                        )
                    }
                }
            }
        }
        .frame(height: 180)
    }

    private func date(for year: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let components = DateComponents(
            year: year,
            month: 1,
            day: 1
        )

        return calendar.date(from: components)!
    }
}
