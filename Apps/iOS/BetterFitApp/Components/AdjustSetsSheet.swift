import SwiftUI

// MARK: - Adjust Sets Sheet

/// A sheet for adjusting the number of sets and reps for an exercise
struct AdjustSetsSheet: View {
    @Environment(\.colorScheme) var colorScheme
    let theme: AppTheme
    let exercise: PlannedExercise
    let onSave: (PlannedExercise) -> Void

    @State private var sets: Int
    @State private var reps: String
    @State private var targetWeight: String

    @Environment(\.dismiss) private var dismiss

    init(theme: AppTheme, exercise: PlannedExercise, onSave: @escaping (PlannedExercise) -> Void) {
        self.theme = theme
        self.exercise = exercise
        self.onSave = onSave
        _sets = State(initialValue: exercise.sets)
        _reps = State(initialValue: exercise.reps)
        _targetWeight = State(initialValue: exercise.targetWeight ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BFColors.backgroundElevated(for: colorScheme).ignoresSafeArea()

                VStack(spacing: 24) {
                    // Exercise name header
                    Text(exercise.name)
                        .font(.title2.weight(.bold))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Sets stepper
                    setsSection

                    // Reps input
                    repsSection

                    // Weight input
                    weightSection

                    Spacer()

                    // Save button
                    Button {
                        save()
                    } label: {
                        Text("Save Changes")
                    }
                    .buttonStyle(.bfPrimary)
                }
                .padding()
            }
            .navigationTitle("Adjust Sets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Sets Section

    private var setsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sets")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))

            HStack(spacing: 16) {
                Button {
                    if sets > 1 { sets -= 1 }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundStyle(sets > 1 ? theme.accent : BFColors.border(for: colorScheme))
                }
                .disabled(sets <= 1)

                Text("\(sets)")
                    .font(BFTypography.statLarge)
                    .frame(width: 50)

                Button {
                    if sets < 10 { sets += 1 }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundStyle(sets < 10 ? theme.accent : BFColors.border(for: colorScheme))
                }
                .disabled(sets >= 10)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(inputBackground)
        }
    }

    // MARK: - Reps Section

    private var repsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reps")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))

            TextField("e.g., 8-12", text: $reps)
                .font(.title3.weight(.semibold))
                .padding()
                .background(inputBackground)
        }
    }

    // MARK: - Weight Section

    private var weightSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Target Weight")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))

            TextField("e.g., 135 lbs", text: $targetWeight)
                .font(.title3.weight(.semibold))
                .padding()
                .background(inputBackground)
        }
    }

    @ViewBuilder
    private var inputBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(BFColors.surfaceRaised(for: colorScheme))
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(BFColors.border(for: colorScheme), lineWidth: 1)
    }

    // MARK: - Actions

    private func save() {
        let updated = PlannedExercise(
            id: exercise.id,
            name: exercise.name,
            category: exercise.category,
            sets: sets,
            reps: reps.isEmpty ? "10" : reps,
            targetWeight: targetWeight.isEmpty ? nil : targetWeight,
            muscleGroups: exercise.muscleGroups
        )
        onSave(updated)
        dismiss()
    }
}

#Preview {
    AdjustSetsSheet(
        theme: .forest,
        exercise: PlannedExercise(
            name: "Bench Press",
            category: .push,
            sets: 4,
            reps: "8-10",
            targetWeight: "185 lbs",
            muscleGroups: ["Chest", "Triceps"]
        )
    ) { _ in }
}
