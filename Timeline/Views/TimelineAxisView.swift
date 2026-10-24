//
//  TimelineAxisView.swift
//  Timeline
//
//  Created by Sunny Suárez Saldaña on 23/10/26.
//



import SwiftUI

struct TimelineAxisView: View {

    let scale: TimelineScale

    private var calendar: Calendar {
        var result = Calendar(identifier: .gregorian)
        result.timeZone = TimeZone(secondsFromGMT: 0)!
        return result
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            ZStack(alignment: .topLeading) {

                // Main horizontal axis
                Rectangle()
                    .fill(.secondary)
                    .frame(width: width, height: 6)
                    .position(
                        x: width / 2,
                        y: height / 2
                    )

                // Visible decade markers
                ForEach(
                    visibleYears(width: width),
                    id: \.self
                ) { year in

                    let x = scale.xPosition(
                        for: date(for: year),
                        viewportWidth: width
                    )

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
                        y: height / 2 + 24
                    )
                }
            }
            .frame(width: width, height: height)
            .clipped()
        }
    }

    // MARK: - Visible Years

    private func visibleYears(width: CGFloat) -> [Int] {

        guard width > 0 else { return [] }

        let leftDate = scale.date(
            at: 0,
            viewportWidth: width
        )

        let rightDate = scale.date(
            at: width,
            viewportWidth: width
        )

        let leftYear = calendar.component(
            .year,
            from: leftDate
        )

        let rightYear = calendar.component(
            .year,
            from: rightDate
        )

        let firstDecade = (leftYear / 10) * 10

        return Array(
            stride(
                from: firstDecade,
                through: rightYear + 10,
                by: 10
            )
        )
    }

    // MARK: - Date Creation

    private func date(for year: Int) -> Date {

        let components = DateComponents(
            year: year,
            month: 1,
            day: 1
        )

        return calendar.date(from: components)!
    }
}
