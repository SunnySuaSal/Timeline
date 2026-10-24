//
//  EventDetailView.swift
//  Timeline
//
//  Created by Sunny Suárez Saldaña on 23/10/26.
//

import SwiftUI
import SwiftData

struct EventDetailView: View {

    // MARK: - Dependencies

    let timeline: Timeline
    let event: TimelineEvent
    let onSaved: (Date) -> Void

    // MARK: - Environment

    @Environment(\.modelContext)
    private var modelContext

    @Environment(\.dismiss)
    private var dismiss

    // MARK: - View State

    @State private var showingEditor = false
    @State private var showingDeleteConfirmation = false
    @State private var deleteError: String?

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

                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {

                        Label(
                            "Delete",
                            systemImage: "trash"
                        )
                    }
                    .help("Delete Event")

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

        // MARK: - Delete Confirmation

        .alert(
            "Delete Event?",
            isPresented: $showingDeleteConfirmation
        ) {

            Button("Cancel", role: .cancel) {
                // No changes are made.
            }

            Button("Delete", role: .destructive) {
                deleteEvent()
            }

        } message: {

            Text(
                "Are you sure you want to delete " +
                "\"\(event.title)\"? " +
                "This action cannot be undone."
            )
        }

        // MARK: - Error Alert

        .alert(
            "Could Not Delete",
            isPresented: Binding(
                get: { deleteError != nil },
                set: {
                    if !$0 {
                        deleteError = nil
                    }
                }
            )
        ) {

            Button("OK", role: .cancel) {
                deleteError = nil
            }

        } message: {

            Text(deleteError ?? "")
        }
    }

    // MARK: - Persistence

    private func deleteEvent() {

        modelContext.delete(event)

        do {
            try modelContext.save()

            dismiss()

        } catch {
            modelContext.rollback()
            deleteError = error.localizedDescription
        }
    }
}
