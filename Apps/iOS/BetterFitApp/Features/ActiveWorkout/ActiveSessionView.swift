import BetterFit
import SwiftUI
#if canImport(UIKit)
    import UIKit
#endif

// MARK: - Live session — Ledger layout

struct ActiveSessionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    let betterFit: BetterFit?
    var theme: AppTheme = .defaultTheme
    let onEnd: () -> Void
    /// Called when the user closes/minimizes back to Plan without finishing.
    var onClose: (() -> Void)? = nil
    var onFinishedSummary: ((WorkoutSummaryData) -> Void)? = nil
    /// When true, rendered inside the Workout tab (no modal chrome expectations).
    var embeddedInTab = false

    @State var exerciseIndex = 0
    @State var setIndex = 0
    @State var weight: Double = 60
    @State var reps: Int = 8
    /// Completed set indexes per exercise (supports completing any open set).
    @State var completedSetIndexes: [UUID: Set<Int>] = [:]
    @State var setOverrides: [UUID: [(load: Double, reps: Int)]] = [:]
    /// ID of the workout this state belongs to. Used to reset kg/reps when
    /// the user starts a new workout session so separate sessions stay
    /// independent and don't inherit the previous session's overrides.
    @State var sessionWorkoutID: UUID?
    /// Custom session order (supports out-of-order training + drag reorder).
    @State var orderedIDs: [UUID] = []
    /// Superset groups: exercise id → shared group id (same id = paired).
    @State var supersetGroup: [UUID: UUID] = [:]
    /// Draft text while typing so fields stay editable mid-keystroke.
    @State var draftLoad: [String: String] = [:]
    @State var draftReps: [String: String] = [:]
    @FocusState var focusedField: FieldFocus?
    @State var resting = false
    @State var remaining = 90
    @State var preferredRest = 90
    @State var startedAt = Date()
    @State var tick = false
    @State var timer: Timer?
    @State var restTimer: Timer?
    @State var showFinish = false
    @State var showAddExercise = false
    @State var editMode: EditMode = .inactive

    enum FieldFocus: Hashable {
        case headerLoad
        case headerReps
        case setLoad(Int)
        case setReps(Int)
    }

    var workout: Workout? { betterFit?.getActiveWorkout() }

    /// Exercises in the user's working order.
    var exercises: [WorkoutExercise] {
        let all = workout?.exercises ?? []
        if orderedIDs.isEmpty { return all }
        let mapped = orderedIDs.compactMap { id in all.first(where: { $0.id == id }) }
        // Append any new exercises not yet in the order list.
        let missing = all.filter { ex in !orderedIDs.contains(ex.id) }
        return mapped + missing
    }

    var current: WorkoutExercise? {
        guard exercises.indices.contains(exerciseIndex) else { return exercises.first }
        return exercises[exerciseIndex]
    }

    var totalExercises: Int { max(exercises.count, 1) }

    func isSuperset(_ id: UUID) -> Bool {
        supersetGroup[id] != nil
    }

    func supersetPartner(of id: UUID) -> UUID? {
        guard let group = supersetGroup[id] else { return nil }
        return orderedIDs.first { $0 != id && supersetGroup[$0] == group }
    }

    func supersetLabel(for id: UUID) -> String? {
        guard let group = supersetGroup[id] else { return nil }
        let members = orderedIDs.filter { supersetGroup[$0] == group }
        guard members.count >= 2, let pos = members.firstIndex(of: id) else { return "Superset" }
        return "Superset \(pos + 1)/\(members.count)"
    }

    var elapsedLabel: String {
        _ = tick
        let secs = Int(Date().timeIntervalSince(startedAt))
        return String(format: "%02d:%02d", secs / 60, secs % 60)
    }

    // MARK: - View

    var body: some View {
        ZStack(alignment: .bottom) {
            BFColors.background(for: colorScheme).ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                if let current {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            exerciseHeader(current)
                            if resting {
                                restBar
                            }
                            quickActions(current)
                            setsSection(current)
                            sessionOrderSection
                            finishButton
                        }
                        .padding(.bottom, 140)
                    }
                } else {
                    emptyState
                }
            }

            if current != nil {
                dock
            }
        }
        .onAppear(perform: bootstrap)
        .onDisappear {
            timer?.invalidate()
            restTimer?.invalidate()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    commitFocusedField()
                    focusedField = nil
                }
                .fontWeight(.semibold)
            }
        }
        .confirmationDialog("Finish workout?", isPresented: $showFinish, titleVisibility: .visible) {
            Button("Finish & save") { finish() }
            Button("Keep training", role: .cancel) {}
        }
        .sheet(isPresented: $showAddExercise) {
            AddExerciseSheet(theme: theme) { planned in
                addExercise(planned)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    ActiveSessionView(betterFit: BetterFit(), onEnd: {})
}
