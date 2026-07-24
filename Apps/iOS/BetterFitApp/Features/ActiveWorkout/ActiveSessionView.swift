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
    @State private var restTimer: RestTimer? = nil

    private var workout: Workout? { betterFit?.getActiveWorkout() }

    var body: some View {
        NavigationStack {
            Group {
                if let workout, !workout.exercises.isEmpty {
                    exerciseList(workout: workout)
                } else {
                    emptyState
                }
            }
            .navigationTitle("Active Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(role: .destructive) {
                        onEnd()
                    } label: {
                        Text("End")
                    }
                }
            }
        }
    }

    // MARK: - Exercise list

    @ViewBuilder
    private func exerciseList(workout: Workout) -> some View {
        ScrollView {
            VStack(spacing: BFSpacing.lg) {
                ForEach(workout.exercises) { we in
                    exerciseCard(we)
                }
            }
            .padding(.horizontal, BFSpacing.lg)
            .padding(.vertical, BFSpacing.md)
        }
    }

    @ViewBuilder
    private func exerciseCard(_ we: WorkoutExercise) -> some View {
        let current = currentSetByExercise[we.id] ?? 0
        let total = we.sets.count
        let logged = setsPerExercise[we.id] ?? []
        VStack(alignment: .leading, spacing: BFSpacing.md) {
            HStack(alignment: .firstTextBaseline) {
                Text(we.exercise.name)
                    .bfHeading(theme: .fitbod, size: 22, relativeTo: .title3)
                Spacer()
                Text("Set \(min(current + 1, max(total, 1))) of \(total)")
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
                            stepperField(
                                label: "Weight",
                                unit: "lbs",
                                binding: weightBinding(for: we.id, default: weightSuggestion(for: we))
                            )
                            stepperField(
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

    // MARK: - Subviews

    @ViewBuilder
    private func stepperField(
        label: String,
        unit: String,
        binding: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(BFTypography.captionEmphasis)
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))
            HStack(spacing: 6) {
                TextField(unit, text: binding)
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
        currentSetByExercise[we.id] = (currentSetByExercise[we.id] ?? 0) + 1
        restTimer = RestTimer(start: Date(), duration: 90)
    }

    private func weightSuggestion(for we: WorkoutExercise) -> String {
        if let w = we.sets.first?.weight { return String(Int(w)) }
        return "0"
    }

    private func repsSuggestion(for we: WorkoutExercise) -> Int {
        we.sets.first?.reps ?? 8
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

    private func formatted(_ weight: Double) -> String {
        weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(weight))
            : String(format: "%.1f", weight)
    }

    @Environment(\.colorScheme) private var colorScheme
}

// MARK: - Local types

struct LoggedSet: Identifiable {
    let id = UUID()
    let reps: Int
    let weight: Double
    let timestamp: Date
}

/// Lightweight rest-timer placeholder; full implementation can extend this
/// to surface a countdown bar above the keyboard. For now it just kicks
/// off a 90-second timer so the lifter can put the phone down between sets.
final class RestTimer: ObservableObject {
    let start: Date
    let duration: TimeInterval

    init(start: Date, duration: TimeInterval) {
        self.start = start
        self.duration = duration
    }

    var endsAt: Date { start.addingTimeInterval(duration) }
}