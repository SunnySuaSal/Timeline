
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
                NavigationLink {
                    TimelineDetailView(timeline: timeline)
                } label: {
                    Label(
                        timeline.name,
                        systemImage: "calendar"
                    )
                }
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
                Section {
                    TextField(
                        "Name",
                        text: $newTimelineName
                    )
                    .textFieldStyle(.roundedBorder)
                } header: {
                    Text("Timeline name")
                } footer: {
                    Text("Choose a descriptive name for your timeline.")
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

    // MARK: - Actions
    
    
    private func addTimeline() {
        let name = newTimelineName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        guard !name.isEmpty else {
            print("DEBUG: Empty timeline name")
            return
        }
        
        print("DEBUG: Creating timeline: \(name)")
        
        let timeline = Timeline(name: name)
        
        modelContext.insert(timeline)
        
        print("DEBUG: Timeline inserted into context")
        
        do {
            try modelContext.save()
            
            print("DEBUG: Timeline saved successfully")
            
            let descriptor = FetchDescriptor<Timeline>()
            let stored = try modelContext.fetch(descriptor)
            
            print("DEBUG: Timelines found: \(stored.count)")
            
            showingAddSheet = false
            
        } catch {
            modelContext.rollback()
            showingAddSheet = false
            saveError = error.localizedDescription
            
            print("ERROR: \(error)")
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

