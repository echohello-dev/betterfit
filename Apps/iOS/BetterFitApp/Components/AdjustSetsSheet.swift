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
            ZStack(alignment: .bottom) {
                BFColors.backgroundElevated(for: colorScheme).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        Text(exercise.name)
                            .font(.title2.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 4)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reps")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(BFColors.textSecondary(for: colorScheme))

                            TextField("e.g., 8-12", text: $reps)
                                .font(.title3.weight(.semibold))
                                .padding()
                                .background(inputBackground)
                        }

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
                    .padding(.horizontal)
                    .padding(.bottom, 120) // clear save button
                }

                Button {
                    save()
                } label: {
                    Text("Save Changes")
                        .font(BFTypography.headline)
                        .foregroundStyle(BFColors.accentInk)
                        .frame(maxWidth: .infinity)
                        .frame(height: BFControlSize.buttonLarge)
                        .background(Capsule(style: .continuous).fill(BFColors.accent))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .navigationTitle("Adjust Sets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 10) {
                        Text("\(sets)")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                        Text("sets")
                            .font(.system(size: 13))
                            .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        save()
                    } label: {
                        Text("Save")
                            .fontWeight(.semibold)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 10) {
                    Button {
                        if sets > 1 { sets -= 1 }
                    } label: {
                        Label("Remove set", systemImage: "minus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(sets > 1 ? BFColors.textPrimary(for: colorScheme) : BFColors.textTertiary(for: colorScheme))
                            .frame(maxWidth: .infinity)
                            .frame(height: BFControlSize.buttonMedium)
                            .background(
                                Capsule()
                                    .fill(BFColors.surfaceRaised(for: colorScheme))
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(sets <= 1)

                    Button {
                        if sets < 10 { sets += 1 }
                    } label: {
                        Label("Add set", systemImage: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(BFColors.accentInk)
                            .frame(maxWidth: .infinity)
                            .frame(height: BFControlSize.buttonMedium)
                            .background(Capsule().fill(BFColors.accent))
                    }
                    .buttonStyle(.plain)
                    .disabled(sets >= 10)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(BFColors.backgroundElevated(for: colorScheme))
            }
        }
    }

    @ViewBuilder
    private var inputBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(BFColors.surfaceRaised(for: colorScheme))
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(BFColors.border(for: colorScheme), lineWidth: 1)
    }

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