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

    // MARK: - Environment

    @Environment(\.modelContext)
    private var modelContext

    @Environment(\.dismiss)
    private var dismiss

    // MARK: - View State

    @State private var title: String
    @State private var eventDate: Date
    @State private var notes: String
    @State private var datePrecision: EventDatePrecision

    @State private var saveError: String?

    // MARK: - Initialization

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

        _datePrecision = State(
            initialValue: event?.datePrecision ?? .day
        )
    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            Form {

                // MARK: - Event Information

                Section("Event") {

                    TextField(
                        "Title",
                        text: $title
                    )

                    Picker(
                        "Date Precision",
                        selection: $datePrecision
                    ) {

                        ForEach(
                            EventDatePrecision.allCases
                        ) { precision in

                            Text(precision.title)
                                .tag(precision)
                        }
                    }

                    DatePicker(
                        "Reference Date",
                        selection: $eventDate,
                        displayedComponents: .date
                    )

                    LabeledContent("Displayed Date") {

                        Text(
                            EventDatePresentation.string(
                                for: eventDate,
                                precision: datePrecision
                            )
                        )
                        .foregroundStyle(.secondary)
                    }

                    Text(precisionExplanation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // MARK: - Notes

                Section("Notes") {

                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .formStyle(.grouped)
            .navigationTitle(
                event == nil ? "New Event" : "Edit Event"
            )

            // MARK: - Toolbar

            .toolbar {

                ToolbarItem(
                    placement: .cancellationAction
                ) {

                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {

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

            // MARK: - Error Alert

            .alert(
                "Could Not Save",
                isPresented: Binding(
                    get: { saveError != nil },
                    set: {
                        if !$0 {
                            saveError = nil
                        }
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

    // MARK: - Precision Explanation

    private var precisionExplanation: String {

        switch datePrecision {

        case .year:
            return "Only the year is known. " +
                   "The month and day will not be displayed."

        case .month:
            return "The month and year are known. " +
                   "The day will not be displayed."

        case .day:
            return "The complete calendar date is known."
        }
    }

    // MARK: - Normalize Date

    private func normalizedDate() -> Date {

        let calendar = Calendar.current

        let components = calendar.dateComponents(
            [.year, .month, .day],
            from: eventDate
        )

        var normalized = DateComponents()

        normalized.year = components.year

        switch datePrecision {

        case .year:
            normalized.month = 1
            normalized.day = 1

        case .month:
            normalized.month = components.month
            normalized.day = 1

        case .day:
            normalized.month = components.month
            normalized.day = components.day
        }

        return calendar.date(from: normalized) ?? eventDate
    }

    // MARK: - Save Event

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

        let finalNotes: String? = cleanNotes.isEmpty
            ? nil
            : cleanNotes

        let finalDate = normalizedDate()

        let savedEvent: TimelineEvent

        if let event {

            // Update existing event

            event.title = cleanTitle
            event.date = finalDate
            event.notes = finalNotes
            event.datePrecision = datePrecision

            savedEvent = event

        } else {

            // Create new event

            let newEvent = TimelineEvent(
                title: cleanTitle,
                date: finalDate,
                notes: finalNotes,
                precision: datePrecision
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
