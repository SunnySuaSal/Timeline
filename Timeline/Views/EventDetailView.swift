//
//  EventDetailView.swift
//  Timeline
//
//  Created by Sunny Suárez Saldaña on 23/10/26.
//

import SwiftUI

struct EventDetailView: View {

    // MARK: - Dependencies

    let timeline: Timeline
    let event: TimelineEvent
    let onSaved: (Date) -> Void

    // MARK: - Environment

    @Environment(\.dismiss)
    private var dismiss

    // MARK: - View State

    @State private var showingEditor = false

    // MARK: - Body

    var body: some View {

        NavigationStack {

            VStack(spacing: 0) {

                // MARK: - Event Information

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

                    // MARK: - Notes

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

                // MARK: - Bottom Action Bar

                Divider()

                HStack(spacing: 12) {

                    Button {
                        showingEditor = true
                    } label: {

                        Label(
                            "Edit",
                            systemImage: "pencil"
                        )
                    }
                    .help("Edit Event")

                    Spacer()

                    Button("Done") {
                        dismiss()
                    }
                    .keyboardShortcut(.defaultAction)
                }
                .padding()
            }
            .navigationTitle("Event Details")
        }
        .frame(
            minWidth: 380,
            minHeight: 300
        )

        // MARK: - Event Editor

        .sheet(isPresented: $showingEditor) {

            EventEditorView(
                timeline: timeline,
                event: event,
                onSaved: onSaved
            )
        }
    }
}
