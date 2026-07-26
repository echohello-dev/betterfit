import BetterFit
import SwiftUI

// MARK: - Active Session Sheet
//
// A minimal set-tracker that appears as a sheet when the user pauses their
// active workout. Lets the lifter log each set (weight + reps), advance to
// the next set / next exercise, and end the workout. Built around
// BetterFit.updateActiveWorkout so logged sets persist into the workout
// record the same way the original ActiveWorkout screens did.

struct ActiveSessionView: View {
    @Environment(\.dismiss) private var dismiss
    let betterFit: BetterFit?
    let onEnd: () -> Void

    @State private var setsPerExercise: [UUID: [LoggedSet]] = [:]
    @State private var weightText: [UUID: String] = [:]
    @State private var repsText: [UUID: String] = [:]
    @State private var currentSetByExercise: [UUID: Int] = [:]
    @State private var restTimer: RestTimerState? = nil
    @State private var preferredRestSeconds: Int = 90
    @State private var selectedExerciseID: UUID?
    @State private var showFinishConfirmation = false

    private var workout: Workout? { betterFit?.getActiveWorkout() }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let restTimer {
                    RestTimerBar(
                        state: restTimer,
                        onSkip: { self.restTimer = nil },
                        onAddSeconds: { self.restTimer?.addSeconds(15) }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                Group {
                    if let workout, !workout.exercises.isEmpty {
                        exerciseList(workout: workout)
                    } else {
                        emptyState
                    }
                }
            }
            .animation(BFAnimation.standard, value: restTimer)
            .navigationTitle("Active Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(role: .destructive) {
                        showFinishConfirmation = true
                    } label: {
                        Text("Finish")
                    }
                }
            }
            .confirmationDialog(
                "Finish Workout?",
                isPresented: $showFinishConfirmation,
                titleVisibility: .visible
            ) {
                Button("Finish & Save") {
                    onEnd()
                    dismiss()
                }
                Button("Keep Training", role: .cancel) {}
            }
        }
    }

    // MARK: - Exercise list

    @ViewBuilder
    private func exerciseList(workout: Workout) -> some View {
        let selectedExercise =
            workout.exercises.first(where: { $0.id == selectedExerciseID })
            ?? workout.exercises.first
        let otherExercises = workout.exercises.filter { $0.id != selectedExercise?.id }

        ScrollView {
            VStack(spacing: BFSpacing.lg) {
                if let selectedExercise {
                    Text("Current exercise")
                        .bfSectionLabel()
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    exerciseCard(selectedExercise)
                }

                if !otherExercises.isEmpty {
                    VStack(alignment: .leading, spacing: BFSpacing.sm) {
                        Text("Exercises")
                            .bfSectionLabel()
                            .foregroundStyle(BFColors.textSecondary(for: colorScheme))

                        ForEach(otherExercises) { exercise in
                            ActiveExercisePickerRow(exercise: exercise) {
                                selectedExerciseID = exercise.id
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, BFSpacing.lg)
            .padding(.vertical, BFSpacing.md)
        }
        .background(BFColors.background(for: colorScheme))
        .onAppear {
            if selectedExerciseID == nil {
                selectedExerciseID = workout.exercises.first?.id
            }
        }
    }

    @ViewBuilder
    private func exerciseCard(_ we: WorkoutExercise) -> some View {
        let current = currentSetByExercise[we.id] ?? 0
        let total = we.sets.count
        let logged = setsPerExercise[we.id] ?? []
        let nextSetLabel = nextSetLabel(we: we, current: current)
        VStack(alignment: .leading, spacing: BFSpacing.md) {
            HStack(alignment: .firstTextBaseline) {
                Text(we.exercise.name)
                    .font(BFTypography.title2)
                Spacer()
                Text(nextSetLabel)
                    .font(BFTypography.captionEmphasis)
                    .foregroundStyle(BFColors.textSecondary(for: colorScheme))
            }

            BFDSCard(padding: BFSpacing.md) {
                VStack(spacing: BFSpacing.sm) {
                    if total == 0 {
                        Text("No sets planned for this exercise.")
                            .font(BFTypography.subheadline)
                            .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                    } else {
                        HStack(spacing: BFSpacing.md) {
                            ActiveSessionField(
                                label: "Weight",
                                unit: "lbs",
                                binding: weightBinding(for: we.id, default: weightSuggestion(for: we))
                            )
                            ActiveSessionField(
                                label: "Reps",
                                unit: "reps",
                                binding: repsBinding(for: we.id, default: "\(repsSuggestion(for: we))")
                            )
                        }

                        Button {
                            logSet(for: we)
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Log Set")
                            }
                        }
                        .buttonStyle(.bfPrimary)
                    }
                }
            }

            if !logged.isEmpty {
                VStack(alignment: .leading, spacing: BFSpacing.xs) {
                    Text("Completed sets")
                        .font(BFTypography.captionEmphasis)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                    ForEach(Array(logged.enumerated()), id: \.offset) { idx, set in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Set \(idx + 1) — \(set.reps) reps × \(formatted(set.weight)) lbs")
                                .font(BFTypography.subheadline)
                                .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(.bottom, BFSpacing.sm)
    }

    private var emptyState: some View {
        VStack(spacing: BFSpacing.md) {
            Image(systemName: "dumbbell")
                .font(.system(size: 44))
                .foregroundStyle(BFColors.textTertiary(for: colorScheme))
            Text("No exercises in this workout.")
                .font(BFTypography.subheadline)
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Actions

    private func logSet(for we: WorkoutExercise) {
        let weight = Double(weightText[we.id] ?? "") ?? we.sets.first?.weight ?? 0
        let reps = Int(repsText[we.id] ?? "") ?? we.sets.first?.reps ?? 0
        guard reps > 0 else { return }

        let logged = LoggedSet(reps: reps, weight: weight, timestamp: Date())
        var entries = setsPerExercise[we.id] ?? []
        entries.append(logged)
        setsPerExercise[we.id] = entries

        // Persist into the workout model.
        if var workout, let idx = workout.exercises.firstIndex(where: { $0.id == we.id }) {
            let updatedSet = ExerciseSet(
                reps: reps,
                weight: weight,
                isCompleted: true,
                timestamp: Date(),
                autoTracked: false
            )
            var updatedSets = workout.exercises[idx].sets
            let pos = currentSetByExercise[we.id] ?? 0
            if pos < updatedSets.count {
                updatedSets[pos] = updatedSet
            } else {
                updatedSets.append(updatedSet)
            }
            workout.exercises[idx].sets = updatedSets
            betterFit?.updateActiveWorkout(workout)
        }

        // Advance.
        let nextSet = (currentSetByExercise[we.id] ?? 0) + 1
        currentSetByExercise[we.id] = nextSet
        if nextSet >= we.sets.count {
            selectNextExercise(after: we.id)
        }

        // Kick off the rest timer. UIImpactFeedbackGenerator gives a small
        // haptic so the lifter knows the set was logged.
        restTimer = RestTimerState(start: Date(), duration: TimeInterval(preferredRestSeconds))
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func weightSuggestion(for we: WorkoutExercise) -> String {
        if let weight = we.sets.first?.weight { return String(Int(weight)) }
        return "0"
    }

    private func repsSuggestion(for we: WorkoutExercise) -> Int {
        we.sets.first?.reps ?? 8
    }

    private func nextSetLabel(we: WorkoutExercise, current: Int) -> String {
        let total = we.sets.count
        if total == 0 { return "No sets" }
        if current >= total { return "Complete" }
        let next = min(current + 1, total)
        return "Set \(next) of \(total)"
    }

    private func selectNextExercise(after exerciseID: UUID) {
        guard let workout,
            let index = workout.exercises.firstIndex(where: { $0.id == exerciseID }),
            workout.exercises.indices.contains(index + 1)
        else {
            return
        }
        selectedExerciseID = workout.exercises[index + 1].id
    }

    private func formatted(_ weight: Double) -> String {
        weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(weight))
            : String(format: "%.1f", weight)
    }

    /// Stable Binding factories that resolve the dictionary at view-build time.
    /// SwiftUI's `$weightText[uuid, default: "0"]` form isn't a Binding in
    /// this version of Swift (the default parameter makes the subscript
    /// a value projection, not a writable one), so we project manually.
    private func weightBinding(for id: UUID, default defaultText: String) -> Binding<String> {
        Binding(
            get: { weightText[id] ?? defaultText },
            set: { weightText[id] = $0 }
        )
    }

    private func repsBinding(for id: UUID, default defaultText: String) -> Binding<String> {
        Binding(
            get: { repsText[id] ?? defaultText },
            set: { repsText[id] = $0 }
        )
    }

    @Environment(\.colorScheme) private var colorScheme
}

// MARK: - Subviews

private struct ActiveExercisePickerRow: View {
    let exercise: WorkoutExercise
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: BFSpacing.md) {
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(BFColors.brandAccent)
                    .frame(width: BFControlSize.minTapTarget, height: BFControlSize.minTapTarget)
                    .background(Circle().fill(BFColors.brandAccent.opacity(0.15)))

                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.exercise.name)
                        .font(BFTypography.subheadlineEmphasis)
                        .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                    Text("\(exercise.sets.count) sets")
                        .font(BFTypography.caption)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BFColors.textTertiary(for: colorScheme))
            }
            .padding(BFSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: BFRadius.card, style: .continuous)
                    .fill(BFColors.surface(for: colorScheme))
            )
            .overlay {
                RoundedRectangle(cornerRadius: BFRadius.card, style: .continuous)
                    .stroke(BFColors.border(for: colorScheme), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct ActiveSessionField: View {
    let label: String
    let unit: String
    @Binding var binding: String

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(BFTypography.captionEmphasis)
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))
            HStack(spacing: 6) {
                TextField(unit, text: $binding)
                    .keyboardType(.decimalPad)
                    .font(BFTypography.headline)
                    .multilineTextAlignment(.center)
                    .frame(minWidth: 48)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: BFRadius.small, style: .continuous)
                            .fill(BFColors.surfaceRaised(for: colorScheme))
                    )
                Text(unit)
                    .font(BFTypography.caption)
                    .foregroundStyle(BFColors.textTertiary(for: colorScheme))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Local types

struct LoggedSet: Identifiable {
    let id = UUID()
    let reps: Int
    let weight: Double
    let timestamp: Date
}

// MARK: - Rest Timer

/// Countdown state for the post-set rest period. Stays in the view as an
/// optional so the bar disappears naturally when the timer ends or is
/// skipped.
struct RestTimerState: Equatable {
    let start: Date
    var duration: TimeInterval

    /// Remaining time in seconds, clamped to zero. Negative values from
    /// elapsed > duration are clamped so the progress / countdown never
    /// display a negative number.
    func remaining(at now: Date) -> TimeInterval {
        let elapsed = now.timeIntervalSince(start)
        return max(0, duration - elapsed)
    }

    func progress(at now: Date) -> Double {
        guard duration > 0 else { return 1 }
        return min(1, max(0, 1 - remaining(at: now) / duration))
    }

    func isFinished(at now: Date) -> Bool {
        remaining(at: now) <= 0
    }

    /// Add extra seconds to the countdown (the '+15s' button).
    mutating func addSeconds(_ seconds: TimeInterval) {
        duration += seconds
    }
}

/// Sticky bar at the top of the active session. Renders a circular ring +
/// mm:ss countdown, a 'Skip' button, and a '+15s' quick-add. Uses
/// TimelineView to redraw every second without a manual Timer.
struct RestTimerBar: View {
    let state: RestTimerState
    let onSkip: () -> Void
    let onAddSeconds: () -> Void

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let now = context.date
            let remaining = state.remaining(at: now)
            let progress = state.progress(at: now)
            let finished = state.isFinished(at: now)

            HStack(spacing: BFSpacing.md) {
                ZStack {
                    Circle()
                        .stroke(BFColors.surfaceRaised(for: scheme), lineWidth: 3)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            finished ? .green : BFColors.brandAccent,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.2), value: progress)

                    Text(formatted(remaining))
                        .font(BFTypography.headline)
                        .monospacedDigit()
                        .foregroundStyle(BFColors.textPrimary(for: scheme))
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 2) {
                    Text(finished ? "Rest done" : "Rest timer")
                        .font(BFTypography.subheadlineEmphasis)
                        .foregroundStyle(BFColors.textPrimary(for: scheme))
                    Text(finished ? "Ready for the next set" : "Between sets")
                        .font(BFTypography.caption)
                        .foregroundStyle(BFColors.textSecondary(for: scheme))
                }

                Spacer()

                Button {
                    onAddSeconds()
                } label: {
                    Text("+15s")
                        .font(BFTypography.captionEmphasis)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule().fill(BFColors.surfaceRaised(for: scheme))
                        )
                        .foregroundStyle(BFColors.textPrimary(for: scheme))
                }
                .buttonStyle(.plain)

                Button(role: .destructive) {
                    onSkip()
                } label: {
                    Text("Skip")
                        .font(BFTypography.captionEmphasis)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, BFSpacing.lg)
            .padding(.vertical, BFSpacing.md)
            .background(BFColors.backgroundElevated(for: scheme))
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(BFColors.separator(for: scheme))
                    .frame(height: 1)
            }
        }
    }

    private func formatted(_ seconds: TimeInterval) -> String {
        let total = Int(seconds.rounded(.up))
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

// MARK: - Animation helper

private enum BFAnimation {
    static let standard: Animation = .easeInOut(duration: 0.25)
}
