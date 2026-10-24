//
//  TimelineEventMarkersView.swift
//  Timeline
//
//  Created by Sunny Suárez Saldaña on 23/10/26.
//


import SwiftUI

struct TimelineEventMarkersView: View {

    let events: [TimelineEvent]
    let scale: TimelineScale
    let onSelect: (TimelineEvent) -> Void

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let middleY = geometry.size.height / 2

            ZStack(alignment: .topLeading) {

                ForEach(events.indices, id: \.self) { index in

                    let event = events[index]

                    let x = scale.xPosition(
                        for: event.date,
                        viewportWidth: width
                    )

                    if x >= 0 && x <= width {

                        let isAbove = index.isMultiple(of: 2)

                        Path { path in
                            path.move(
                                to: CGPoint(
                                    x: x,
                                    y: middleY
                                )
                            )

                            path.addLine(
                                to: CGPoint(
                                    x: x,
                                    y: middleY
                                        + (isAbove ? -30 : 30)
                                )
                            )
                        }
                        .stroke(
                            Color.accentColor,
                            lineWidth: 1.5
                        )

                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 11, height: 11)
                            .position(x: x, y: middleY)

                        Button {
                            onSelect(event)
                        } label: {

                            VStack(spacing: 3) {

                                Text(event.title)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .lineLimit(1)

                                Text(
                                    event.date,
                                    format: .dateTime.year()
                                )
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            }
                            .frame(width: 125)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .position(
                            x: x,
                            y: middleY + (isAbove ? -48 : 48)
                        )
                    }
                }
            }
            .frame(width: width, height: geometry.size.height)
        }
        //.allowsHitTesting(false)
    }
}
