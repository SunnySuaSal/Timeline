//
//  TimelineDetailView.swift
//  Timeline
//
//  Created by Sunny Suárez Saldaña on 22/10/26.
//




import SwiftUI

struct TimelineDetailView: View {

    let timeline: Timeline

    // MARK: - Persistent View State

    @State private var scale = TimelineScale(
        centerDate: Calendar(
            identifier: .gregorian
        ).date(
            from: DateComponents(
                year: 1980,
                month: 1,
                day: 1
            )
        )!,
        pointsPerYear: 12
    )

    // MARK: - Temporary Gesture State

    @GestureState private var dragTranslation: CGFloat = 0
    @GestureState private var magnification: CGFloat = 1

    // MARK: - Effective Scale

    private var effectiveScale: TimelineScale {
        scale
            .panned(by: dragTranslation)
            .zoomed(by: magnification)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 24) {

            Text(timeline.name)
                .font(.largeTitle)
                .bold()

            Text("\(timeline.events.count) events")
                .foregroundStyle(.secondary)

            TimelineAxisView(scale: effectiveScale)
                .contentShape(Rectangle())
                .gesture(dragGesture)
                .simultaneousGesture(magnifyGesture)

            Text("Drag to navigate. Pinch to zoom.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .padding()
        .navigationTitle(timeline.name)
    }

    // MARK: - Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .updating($dragTranslation) {
                value, state, _ in

                state = value.translation.width
            }
            .onEnded { value in
                scale = scale.panned(
                    by: value.translation.width
                )
            }
    }

    // MARK: - Magnification Gesture

    private var magnifyGesture: some Gesture {
        MagnifyGesture()
            .updating($magnification) {
                value, state, _ in

                state = value.magnification
            }
            .onEnded { value in
                scale = scale.zoomed(
                    by: value.magnification
                )
            }
    }
}
