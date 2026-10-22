
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
    @State private var saveError: String?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List(timelines) { timeline in
                Label(
                    timeline.name,
                    systemImage: "calendar"
                )
            }
            .navigationTitle("Timelines")
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
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        newTimelineName = ""
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                addTimelineSheet
            }
            .alert(
                "Could Not Save",
                isPresented: Binding(
                    get: { saveError != nil },
                    set: { if !$0 { saveError = nil } }
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
                TextField(
                    "Timeline name",
                    text: $newTimelineName
                )
            }
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
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .isEmpty
                    )
                }
            }
        }
        .frame(minWidth: 320, minHeight: 220)
    }

    // MARK: - Actions

    private func addTimeline() {
        let name = newTimelineName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !name.isEmpty else { return }

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
}


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

