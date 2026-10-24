//
//  EventDetailView.swift
//  Timeline
//
//  Created by Sunny Suárez Saldaña on 23/10/26.
//

import SwiftUI

struct EventDetailView: View {

    let event: TimelineEvent

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {

        NavigationStack {

            Form {

                Section("Event") {

                    LabeledContent(
                        "Title",
                        value: event.title
                    )

                    LabeledContent {
                        Text(
                            event.date,
                            format: .dateTime
                                .day()
                                .month(.wide)
                                .year()
                        )
                    } label: {
                        Text("Date")
                    }
                }

                Section("Notes") {

                    if let notes = event.notes,
                       !notes.isEmpty {

                        Text(notes)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )

                    } else {

                        Text("No notes available.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Event Details")
            .toolbar {

                ToolbarItem(placement: .confirmationAction) {

                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 380, minHeight: 300)
    }
}
