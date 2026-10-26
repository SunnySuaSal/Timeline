//
//  TimelineEventMarkersView.swift
//  Timeline
//
//  Created by Sunny Suárez Saldaña on 23/10/26.
//


import SwiftUI

struct TimelineEventMarkersView: View {

    // MARK: - Dependencies

    let events: [TimelineEvent]
    let scale: TimelineScale
    let onSelect: (TimelineEvent) -> Void

    // MARK: - Layout Configuration

    private let labelWidth: CGFloat = 160
    private let labelGap: CGFloat = 12

    private let baseDistance: CGFloat = 82
    private let laneSpacing: CGFloat = 55

    private let lanesPerSide = 2

    // MARK: - Layout Model

    private struct MarkerPlacement {

        let event: TimelineEvent
        let x: CGFloat

        // -1 = above, +1 = below
        let side: CGFloat

        // nil means no available label lane
        let lane: Int?
    }

    // MARK: - Body

    var body: some View {

        GeometryReader { geometry in

            let width = geometry.size.width
            let middleY = geometry.size.height / 2

            let placements = calculatePlacements(
                viewportWidth: width
            )

            ZStack(alignment: .topLeading) {

                ForEach(placements.indices, id: \.self) { index in

                    let placement = placements[index]

                    let x = placement.x
                    let event = placement.event

                    // MARK: - Event Point

                    Button {
                        onSelect(event)
                    } label: {

                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 11, height: 11)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .position(
                        x: x,
                        y: middleY
                    )

                    // MARK: - Event Label

                    if let lane = placement.lane {

                        let distance =
                            baseDistance
                            + CGFloat(lane) * laneSpacing

                        let labelY =
                            middleY
                            + placement.side * distance

                        let lineEndY =
                            middleY
                            + placement.side * (distance - 20)

                        // Connector line

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
                                    y: lineEndY
                                )
                            )
                        }
                        .stroke(
                            Color.accentColor,
                            lineWidth: 1.5
                        )
                        .allowsHitTesting(false)

                        // Interactive label

                        Button {
                            onSelect(event)
                        } label: {

                            VStack(spacing: 3) {

                                Text(event.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)

                                Text(
                                    EventDatePresentation.string(
                                        for: event.date,
                                        precision: event.datePrecision
                                    )
                                )
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            }
                            .frame(width: labelWidth)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .position(
                            x: x,
                            y: labelY
                        )
                    }
                }
            }
            .frame(
                width: width,
                height: geometry.size.height
            )
        }
    }

    // MARK: - Layout Algorithm

    private func calculatePlacements(
        viewportWidth width: CGFloat
    ) -> [MarkerPlacement] {

        // Last occupied horizontal position
        // for each lane on each side.

        var upperLanes = Array(
            repeating: -CGFloat.infinity,
            count: lanesPerSide
        )

        var lowerLanes = Array(
            repeating: -CGFloat.infinity,
            count: lanesPerSide
        )

        var placements: [MarkerPlacement] = []

        for (index, event) in events.enumerated() {

            let x = scale.xPosition(
                for: event.date,
                viewportWidth: width
            )

            // Skip events outside the viewport.

            guard x >= 0 && x <= width else {
                continue
            }

            let preferredSide: CGFloat =
                index.isMultiple(of: 2) ? -1 : 1

            let leftEdge = x - labelWidth / 2
            let rightEdge = x + labelWidth / 2

            var assignedSide = preferredSide
            var assignedLane: Int?

            // Avoid labels crossing viewport edges.

            if leftEdge >= 0 && rightEdge <= width {

                // First try the preferred side.

                if preferredSide < 0 {
                    assignedLane = findAvailableLane(
                        leftEdge: leftEdge,
                        rightEdge: rightEdge,
                        lanes: &upperLanes
                    )
                } else {
                    assignedLane = findAvailableLane(
                        leftEdge: leftEdge,
                        rightEdge: rightEdge,
                        lanes: &lowerLanes
                    )
                }

                // Otherwise try the opposite side.

                if assignedLane == nil {

                    assignedSide = -preferredSide

                    if assignedSide < 0 {
                        assignedLane = findAvailableLane(
                            leftEdge: leftEdge,
                            rightEdge: rightEdge,
                            lanes: &upperLanes
                        )
                    } else {
                        assignedLane = findAvailableLane(
                            leftEdge: leftEdge,
                            rightEdge: rightEdge,
                            lanes: &lowerLanes
                        )
                    }
                }
            }

            placements.append(
                MarkerPlacement(
                    event: event,
                    x: x,
                    side: assignedSide,
                    lane: assignedLane
                )
            )
        }

        return placements
    }

    // MARK: - Lane Selection

    private func findAvailableLane(
        leftEdge: CGFloat,
        rightEdge: CGFloat,
        lanes: inout [CGFloat]
    ) -> Int? {

        for index in lanes.indices {

            if leftEdge >= lanes[index] + labelGap {

                lanes[index] = rightEdge

                return index
            }
        }

        return nil
    }
}
