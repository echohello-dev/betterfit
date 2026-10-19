import BetterFit
import SwiftUI

struct WorkoutActionsView: View {
    @EnvironmentObject var appState: WatchAppState
    @Environment(\.dismiss) private var dismiss
    @State private var showsDiscardConfirmation = false
    let editValue: (WorkoutValue) -> Void

    // MARK: - View

    var body: some View {
        NavigationStack {
            List {
                if let session = appState.session {
                    if !session.isFinished {
                        Button(
                            session.isPaused ? "Resume" : "Pause",
                            systemImage: session.isPaused ? "play.fill" : "pause.fill"
                        ) {
                            appState.togglePause()
                            dismiss()
                        }
                        .frame(minHeight: 44)
                        .accessibilityIdentifier("toggle-pause")
                    }
                    Button("Undo Last Set", systemImage: "arrow.uturn.backward") {
                        appState.undoLastSet()
                        dismiss()
                    }
                    .frame(minHeight: 44)
                    .disabled(!session.canUndoLastSet)
                    .accessibilityIdentifier("undo-last-set")

                    if session.remainingRest() > 0 {
                        Button("Skip Rest", systemImage: "forward.end.fill") {
                            appState.session?.skipRest()
                            dismiss()
                        }
                        .frame(minHeight: 44)
                        .accessibilityIdentifier("skip-rest")
                    }

                    if !session.isFinished {
                        Section {
                            Button("Edit Reps", systemImage: "plusminus") { editValue(.reps) }
                                .frame(minHeight: 44)
                                .accessibilityIdentifier("edit-reps-with-buttons")
                            if session.currentSet?.weight != nil {
                                Button("Edit Weight", systemImage: "dumbbell") { editValue(.weight) }
                                    .frame(minHeight: 44)
                                    .accessibilityIdentifier("edit-weight-with-buttons")
                            }
                        } footer: {
                            Text("For quick changes, tap a value on the workout screen and turn the Crown.")
                        }
                        .disabled(session.isPaused)
                    }

                    Section {
                        Picker("Auto Rest", selection: restDuration) {
                            Text("Off").tag(0.0)
                            ForEach([30, 60, 90, 120, 180], id: \.self) { seconds in
                                Text("\(seconds) sec").tag(Double(seconds))
                            }
                        }
                        .accessibilityIdentifier("rest-duration")
                    } footer: {
                        Text("Rest starts after each set. Keep logging whenever you’re ready.")
                    }
                    Section {
                        Text(session.workout.name).font(.headline)
                        Text("\(session.completedSetCount) of \(session.totalSetCount) sets logged")
                            .font(.caption)
                        WorkoutElapsedTime(session: session)
                    }
                    Button("Discard Workout", systemImage: "trash", role: .destructive) {
                        showsDiscardConfirmation = true
                    }
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("discard-workout")
                }
            }
            .navigationTitle("Actions")
            .confirmationDialog(
                "Discard this workout?", isPresented: $showsDiscardConfirmation, titleVisibility: .visible
            ) {
                Button("Discard", role: .destructive) { appState.discardWorkout() }
                Button("Keep Tracking", role: .cancel) { }
            } message: {
                Text("Your logged sets will not be saved.")
            }
        }
        .tint(WatchTheme.surfaceRaised)
    }

    // MARK: - Rest Preference

    private var restDuration: Binding<Double> {
        Binding(
            get: { appState.session?.restDuration ?? 60 },
            set: { appState.setRestDuration($0) }
        )
    }
}
