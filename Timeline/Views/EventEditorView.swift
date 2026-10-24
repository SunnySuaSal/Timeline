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
    let event: TimelineEvent?
    let onSaved: (Date) -> Void
    
    
    @Environment(\.modelContext)
    private var modelContext
    
    @Environment(\.dismiss)
    private var dismiss
    
    // MARK: - Form State
    
    @State private var title: String
    @State private var eventDate: Date
    @State private var notes: String
    @State private var saveError: String?
    
    // MARK: - Initializer
    init(
        timeline: Timeline,
        event: TimelineEvent? = nil,
        onSaved: @escaping (Date) -> Void
    ) {
        self.timeline = timeline
        self.event = event
        self.onSaved = onSaved

        _title = State(
            initialValue: event?.title ?? ""
        )

        _eventDate = State(
            initialValue: event?.date ?? .now
        )

        _notes = State(
            initialValue: event?.notes ?? ""
        )
    }

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
            .navigationTitle(
                event == nil ? "New Event" : "Edit Event"
            )
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

        guard !cleanTitle.isEmpty else {
            return
        }

        let cleanNotes = notes.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let finalNotes: String? =
            cleanNotes.isEmpty ? nil : cleanNotes

        let savedEvent: TimelineEvent

        if let event {

            // Edit an existing event.

            event.title = cleanTitle
            event.date = eventDate
            event.notes = finalNotes

            savedEvent = event

        } else {

            // Create a new event.

            let newEvent = TimelineEvent(
                title: cleanTitle,
                date: eventDate,
                notes: finalNotes
            )

            newEvent.timeline = timeline

            modelContext.insert(newEvent)

            savedEvent = newEvent
        }

        do {
            try modelContext.save()

            onSaved(savedEvent.date)

            dismiss()

        } catch {
            modelContext.rollback()
            saveError = error.localizedDescription
        }
    }
}
