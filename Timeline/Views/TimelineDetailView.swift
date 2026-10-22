//
//  TimelineDetailView.swift
//  Timeline
//
//  Created by Sunny Suárez Saldaña on 22/10/26.
//


import SwiftUI
import SwiftData

struct TimelineDetailView: View {

    let timeline: Timeline

    var body: some View {
        VStack(spacing: 20) {

            Image(systemName: "calendar")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(timeline.name)
                .font(.largeTitle)
                .bold()
            
            Text("\(timeline.events.count) events")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("No events yet")
                .font(.headline)

            Text("Events will appear here.")
                .foregroundStyle(.secondary)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .navigationTitle(timeline.name)
    }
}
