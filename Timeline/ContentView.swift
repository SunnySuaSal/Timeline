
import SwiftUI
import SwiftData

struct ContentView: View {

    // MARK: - Persistence

    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \Timeline.createdAt)
    private var timelines: [Timeline]

    // MARK: - View State

    @State private var showingAddSheet = false
    @State private var newTimelineName = ""

    @State private var timelineToRename: Timeline?
    @State private var editedTimelineName = ""

    @State private var timelineToDelete: Timeline?
    @State private var showingDeleteConfirmation = false

    @State private var saveError: String?

    // MARK: - Body

    var body: some View {

        NavigationStack {

            List(timelines) { timeline in

                NavigationLink {

                    TimelineDetailView(timeline: timeline)

                } label: {

                    Label(
                        timeline.name,
                        systemImage: "calendar"
                    )
                }

                // MARK: - Context Menu

                .contextMenu {

                    Button {
                        beginRenaming(timeline)
                    } label: {

                        Label(
                            "Rename",
                            systemImage: "pencil"
                        )
                    }

                    Divider()

                    Button(role: .destructive) {

                        timelineToDelete = timeline
                        showingDeleteConfirmation = true

                    } label: {

                        Label(
                            "Delete Timeline",
                            systemImage: "trash"
                        )
                    }
                }
            }
            .navigationTitle("Timelines")

            // MARK: - Empty State

            .overlay {

                if timelines.isEmpty {

                    ContentUnavailableView(
                        "No Timelines",
                        systemImage: "calendar",
                        description: Text(
                            "Create your first timeline."
                        )
                    )
                }
            }

            // MARK: - Toolbar

            .toolbar {

                ToolbarItem(placement: .primaryAction) {

                    Button {

                        newTimelineName = ""
                        showingAddSheet = true

                    } label: {

                        Image(systemName: "plus")
                    }
                    .help("Add Timeline")
                }
            }

            // MARK: - Add Timeline

            .sheet(isPresented: $showingAddSheet) {
                addTimelineSheet
            }

            // MARK: - Rename Timeline

            .sheet(item: $timelineToRename) { timeline in
                renameTimelineSheet(timeline)
            }

            // MARK: - Delete Confirmation

            .alert(
                "Delete Timeline?",
                isPresented: $showingDeleteConfirmation
            ) {

                Button("Cancel", role: .cancel) {
                    timelineToDelete = nil
                }

                Button("Delete", role: .destructive) {
                    deleteTimeline()
                }

            } message: {

                if let timeline = timelineToDelete {

                    Text(
                        "Are you sure you want to delete " +
                        "\"\(timeline.name)\" and all its " +
                        "\(timeline.events.count) events? " +
                        "This action cannot be undone."
                    )
                }
            }

            // MARK: - Error Alert

            .alert(
                "Could Not Save Changes",
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
    }

    // MARK: - Add Timeline Sheet

    private var addTimelineSheet: some View {

        NavigationStack {

            Form {

                Section {

                    TextField(
                        "Name",
                        text: $newTimelineName
                    )
                    .textFieldStyle(.roundedBorder)

                } header: {

                    Text("Timeline name")

                } footer: {

                    Text(
                        "Choose a descriptive name for your timeline."
                    )
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Timeline")

            .toolbar {

                ToolbarItem(placement: .cancellationAction) {

                    Button("Cancel") {
                        showingAddSheet = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {

                    Button("Add") {
                        addTimeline()
                    }
                    .disabled(
                        newTimelineName
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty
                    )
                }
            }
        }
        .frame(minWidth: 400, minHeight: 250)
    }

    // MARK: - Rename Timeline Sheet

    private func renameTimelineSheet(
        _ timeline: Timeline
    ) -> some View {

        NavigationStack {

            VStack(spacing: 0) {

                Form {

                    Section("Timeline name") {

                        TextField(
                            "Name",
                            text: $editedTimelineName
                        )
                        .textFieldStyle(.roundedBorder)
                    }
                }
                .formStyle(.grouped)

                Divider()

                HStack {

                    Button("Cancel") {
                        timelineToRename = nil
                    }

                    Spacer()

                    Button("Save") {
                        renameTimeline(timeline)
                    }
                    .disabled(
                        editedTimelineName
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty
                    )
                    .keyboardShortcut(.defaultAction)
                }
                .padding()
            }
            .navigationTitle("Rename Timeline")
        }
        .frame(minWidth: 400, minHeight: 250)
    }

    // MARK: - Create Timeline

    private func addTimeline() {

        let name = newTimelineName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !name.isEmpty else {
            return
        }

        let timeline = Timeline(name: name)

        modelContext.insert(timeline)

        do {
            try modelContext.save()
            showingAddSheet = false

        } catch {
            modelContext.rollback()
            showingAddSheet = false
            saveError = error.localizedDescription
        }
    }

    // MARK: - Begin Renaming

    private func beginRenaming(
        _ timeline: Timeline
    ) {

        editedTimelineName = timeline.name

        timelineToRename = timeline
    }

    // MARK: - Rename Timeline

    private func renameTimeline(
        _ timeline: Timeline
    ) {

        let newName = editedTimelineName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !newName.isEmpty else {
            return
        }

        timeline.name = newName

        do {
            try modelContext.save()

            timelineToRename = nil

        } catch {
            modelContext.rollback()

            timelineToRename = nil
            saveError = error.localizedDescription
        }
    }

    // MARK: - Delete Timeline

    private func deleteTimeline() {

        guard let timeline = timelineToDelete else {
            return
        }

        modelContext.delete(timeline)

        do {
            try modelContext.save()

            timelineToDelete = nil

        } catch {
            modelContext.rollback()

            timelineToDelete = nil
            saveError = error.localizedDescription
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(
            for: [
                Timeline.self,
                TimelineEvent.self
            ],
            inMemory: true
        )
}
