//
//  TimelineDetailView.swift
//  Timeline
//
//  Created by Sunny Suárez Saldaña on 22/10/26.
//






import SwiftUI

struct TimelineDetailView: View {

    let timeline: Timeline

    // MARK: - View State

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

    @State private var showingEventEditor = false
    @State private var selectedEvent: TimelineEvent?

    // MARK: - Gesture State

    @GestureState private var dragTranslation: CGFloat = 0
    @GestureState private var magnification: CGFloat = 1

    // MARK: - Computed Properties

    private var sortedEvents: [TimelineEvent] {
        timeline.events.sorted {
            $0.date < $1.date
        }
    }

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

            timelineContent
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .padding()
        .navigationTitle(timeline.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingEventEditor = true
                } label: {
                    Image(systemName: "plus")
                }
                .help("Add Event")
            }
        }
        .sheet(isPresented: $showingEventEditor) {
            EventEditorView(timeline: timeline) { date in
                scale.centerDate = date
            }
        }
        .sheet(item: $selectedEvent) { event in

            EventDetailView(
                timeline: timeline,
                event: event
            ) { date in

                scale.centerDate = date
            }
        }
    }

    // MARK: - Timeline Content

    private var timelineContent: some View {
        ZStack {

            #if os(macOS)

            TimelineAxisView(scale: scale)
                .overlay {
                    TrackpadInputView(
                        onScroll: { delta in
                            scale = scale.panned(by: delta)
                        },
                        onMagnify: { factor in
                            scale = scale.zoomed(by: factor)
                        }
                    )
                }

            TimelineEventMarkersView(
                events: sortedEvents,
                scale: scale,
                onSelect: { event in
                    selectedEvent = event
                }
            )

            #else

            TimelineAxisView(scale: effectiveScale)
                .contentShape(Rectangle())
                .gesture(dragGesture)
                .simultaneousGesture(magnifyGesture)

            TimelineEventMarkersView(
                events: sortedEvents,
                scale: effectiveScale,
                onSelect: { event in
                    selectedEvent = event
                }
            )

            #endif
        }
        .frame(height: 180)
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
