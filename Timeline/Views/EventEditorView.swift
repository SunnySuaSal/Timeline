//
//  EventEditorView.swift
//  Timeline
//
//  Created by Sunny Suárez Saldaña on 23/10/26.
//


import SwiftUI
import SwiftData

struct EventEditorView: View {

    let timeline: Timeline
    let onSaved: (Date) -> Void

    @Environment(\.modelContext)
    private var modelContext

    @Environment(\.dismiss)
    private var dismiss

    // MARK: - Form State

    @State private var title = ""
    @State private var eventDate = Date.now
    @State private var notes = ""
    @State private var saveError: String?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section("Event") {
                    TextField(
                        "Title",
                        text: $title
                    )

                    DatePicker(
                        "Date",
                        selection: $eventDate,
                        displayedComponents: .date
                    )
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEvent()
                    }
                    .disabled(
                        title.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                }
            }
            .alert(
                "Could Not Save",
                isPresented: Binding(
                    get: { saveError != nil },
                    set: {
                        if !$0 { saveError = nil }
                    }
                )
            ) {
                Button("OK", role: .cancel) {
                    saveError = nil
                }
            } message: {
                Text(saveError ?? "")
            }
        }
        .frame(minWidth: 320, minHeight: 380)
    }

    // MARK: - Persistence

    private func saveEvent() {

        let cleanTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanTitle.isEmpty else { return }

        let cleanNotes = notes.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let event = TimelineEvent(
            title: cleanTitle,
            date: eventDate,
            notes: cleanNotes.isEmpty ? nil : cleanNotes
        )

        event.timeline = timeline
        modelContext.insert(event)

        do {
            try modelContext.save()

            onSaved(eventDate)
            dismiss()

        } catch {
            modelContext.rollback()
            saveError = error.localizedDescription
        }
    }
}
