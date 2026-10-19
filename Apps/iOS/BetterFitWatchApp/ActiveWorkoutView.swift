import BetterFit
import SwiftUI
import WatchKit

struct ActiveWorkoutView: View {
    @EnvironmentObject var appState: WatchAppState
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var presentedSheet: WorkoutSheet?
    @FocusState private var crownValue: WorkoutValue?
    @State private var crownSelection: WorkoutValue?

    // MARK: - View

    var body: some View {
        VStack(spacing: 4) {
            ViewThatFits(in: .vertical) {
                workoutContent
                ScrollView { workoutContent }
                    .contentMargins(.vertical, 0, for: .scrollContent)
            }
            HStack(spacing: 8) {
                primaryAction
                actionsButton
            }
            .padding(.horizontal, 4)
            .fixedSize(horizontal: false, vertical: true)
        }
        .background(WatchTheme.background.ignoresSafeArea())
        .tint(WatchTheme.accent)
        .foregroundStyle(WatchTheme.textPrimary)
        .sheet(item: $presentedSheet) { sheet in
            if let value = WorkoutValue(rawValue: sheet.rawValue) {
                WorkoutValueEditor(value: value)
                    .environmentObject(appState)
            } else {
                WorkoutActionsView(editValue: showValueEditor)
                    .environmentObject(appState)
            }
        }
        .onChange(of: appState.session?.currentSet?.id) { _, _ in releaseCrown() }
        .onChange(of: appState.session?.isPaused) { _, paused in
            if paused == true { releaseCrown() }
        }
        .task(id: crownSelection) {
            // Make the field eligible for editing before requesting native focus.
            let selection = crownSelection
            await Task.yield()
            guard crownSelection == selection else { return }
            crownValue = selection
        }
        .task(id: restCueID) { await playRestCue() }
    }

    private var workoutContent: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let session = appState.session {
                if let exercise = session.currentExerciseIndex,
                    let setIndex = session.currentSetIndex, let set = session.currentSet {
                    exerciseHeader(session: session, exercise: exercise, set: setIndex)
                    values(for: set)
                        .id(set.id)
                        .disabled(session.isPaused)
                } else {
                    summary(session)
                }
            }
        }
        .padding(.horizontal, 4)
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Current Set

    private func exerciseHeader(session: WorkoutTrackingSession, exercise: Int, set: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(session.workout.exercises[exercise].exercise.name)
                .font(.subheadline.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("current-exercise")
            WorkoutSetContext(
                session: session, setNumber: set + 1,
                setCount: session.workout.exercises[exercise].sets.count
            )
        }
    }

    @ViewBuilder
    private func values(for set: ExerciseSet) -> some View {
        if dynamicTypeSize >= .xxLarge {
            VStack(spacing: 8) { valueButtons(for: set) }
        } else {
            HStack(spacing: 8) { valueButtons(for: set) }
        }
    }

    @ViewBuilder
    private func valueButtons(for set: ExerciseSet) -> some View {
        WorkoutValueButton(
            metric: .reps, amount: WorkoutValue.reps.binding(to: appState), crownFocus: $crownValue,
            editingEnabled: crownSelection == .reps, select: { selectCrown(.reps) },
            useButtons: { showValueEditor(.reps) }
        )
        if set.weight != nil {
            WorkoutValueButton(
                metric: .weight, amount: WorkoutValue.weight.binding(to: appState), crownFocus: $crownValue,
                editingEnabled: crownSelection == .weight, select: { selectCrown(.weight) },
                useButtons: { showValueEditor(.weight) }
            )
        }
    }

    private func selectCrown(_ value: WorkoutValue) {
        if crownSelection == value {
            crownValue = value
        } else {
            crownSelection = value
        }
    }

    private func releaseCrown() {
        crownSelection = nil
        crownValue = nil
    }

    private func showValueEditor(_ value: WorkoutValue) {
        releaseCrown()
        presentedSheet = value == .reps ? .reps : .weight
    }

    private var actionsButton: some View {
        Button {
            releaseCrown()
            presentedSheet = .actions
        } label: {
            Image(systemName: "ellipsis")
                .font(.body.bold())
                .frame(width: 44, height: 44)
                .background(WatchTheme.surfaceRaised, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Workout actions")
        .accessibilityIdentifier("workout-actions")
    }

    // MARK: - Primary Action

    @ViewBuilder
    private var primaryAction: some View {
        if let session = appState.session {
            if session.isPaused && !session.isFinished {
                actionButton("Resume", symbol: "play.fill", identifier: "toggle-pause") {
                    appState.togglePause()
                }
            } else if let set = session.currentSet {
                actionButton("Log Set", symbol: "checkmark", identifier: "complete-set") {
                    appState.logSet(id: set.id)
                }
                .accessibilityValue(
                    set.weight.map { "\(set.reps) reps, \($0.formatted()) pounds" } ?? "\(set.reps) reps"
                )
                .accessibilityHint("Logs this set and advances to the next one.")
            } else if session.totalSetCount > 0 {
                actionButton("Save Workout", symbol: "checkmark", identifier: "save-workout") {
                    appState.completeWorkout()
                }
            }
        }
    }

    private func actionButton(
        _ title: String, symbol: String, identifier: String, action: @escaping () -> Void
    ) -> some View {
        WatchPrimaryAction(
            title: title, symbol: symbol, gestureEnabled: presentedSheet == nil, action: action
        )
            .accessibilityIdentifier(identifier)
    }

    private func summary(_ session: WorkoutTrackingSession) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(session.totalSetCount > 0 ? "Workout complete" : "No sets to log", systemImage: "checkmark.circle")
                .font(.headline)
                .accessibilityIdentifier("workout-summary")
            Text(session.workout.name).font(.body)
            Text("\(session.completedSetCount) sets logged")
                .font(.caption)
                .foregroundStyle(WatchTheme.textSecondary)
            WorkoutElapsedTime(session: session)
            if session.canUndoLastSet {
                Button("Undo Last Set", systemImage: "arrow.uturn.backward") { appState.undoLastSet() }
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("undo-last-set")
            }
        }
    }

    // MARK: - Rest Feedback

    private var restCueID: RestCueID {
        RestCueID(
            rest: appState.session?.restID, paused: appState.session?.isPaused ?? false,
            duration: appState.session?.restDuration ?? 0, active: scenePhase == .active
        )
    }

    private func playRestCue() async {
        guard scenePhase == .active, let session = appState.session, !session.isPaused else { return }
        let remaining = session.remainingRest()
        guard remaining > 0 else { return }
        do {
            try await Task.sleep(for: .seconds(remaining))
            WKInterfaceDevice.current().play(.notification)
        } catch { /* Pausing, skipping, or leaving the screen cancels the cue. */ }
    }

    private enum WorkoutSheet: String, Identifiable {
        case actions, reps, weight
        var id: String { rawValue }
    }

    private struct RestCueID: Equatable {
        let rest: UUID?
        let paused: Bool
        let duration: TimeInterval
        let active: Bool
    }
}
