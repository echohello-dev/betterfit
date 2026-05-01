import BetterFit
import SwiftUI

// MARK: - Exercise Detail Sheet

struct ExerciseDetailSheet: View {
    let exercise: PlannedExercise
    let theme: AppTheme
    let onDelete: () -> Void
    let onReplace: () -> Void
    let onSuperset: () -> Void
    let onUpdate: (PlannedExercise) -> Void

    @AppStorage(WeightUnitSetting.storageKey) private var weightUnit: String = WeightUnitSetting.lbs
        .rawValue

    @State private var sets: Int
    @State private var reps: String
    @State private var weight: Double

    @Environment(\.dismiss) private var dismiss

    init(
        exercise: PlannedExercise,
        theme: AppTheme,
        onDelete: @escaping () -> Void,
        onReplace: @escaping () -> Void,
        onSuperset: @escaping () -> Void,
        onUpdate: @escaping (PlannedExercise) -> Void
    ) {
        self.exercise = exercise
        self.theme = theme
        self.onDelete = onDelete
        self.onReplace = onReplace
        self.onSuperset = onSuperset
        self.onUpdate = onUpdate

        // Initialize state from exercise
        _sets = State(initialValue: exercise.sets)
        _reps = State(initialValue: exercise.reps)

        // Parse weight from string
        let weightValue =
            Double(
                exercise.targetWeight?.components(separatedBy: CharacterSet.decimalDigits.inverted)
                    .first ?? "0") ?? 0
        _weight = State(initialValue: weightValue)
    }

    private var currentUnit: WeightUnitSetting {
        WeightUnitSetting(rawValue: weightUnit) ?? .lbs
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Video placeholder
                    videoPlaceholder

                    // Exercise title and category
                    exerciseHeader

                    // Quick action buttons
                    quickActionButtons

                    Divider()
                        .padding(.vertical, 8)

                    // Sets adjustment
                    setsAdjustmentSection

                    Divider()
                        .padding(.vertical, 8)

                    // Weight unit toggle
                    weightUnitSection

                    Spacer(minLength: 40)
                }
                .padding(20)
            }
            .background(theme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Exercise Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Video Placeholder

    private var videoPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 200)

            VStack(spacing: 12) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.white.opacity(0.9))

                Text("Demo Video")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .overlay(alignment: .topTrailing) {
            Text("AUTO-PLAY")
                .font(.caption2.weight(.bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(12)
        }
    }

    // MARK: - Exercise Header

    private var exerciseHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise.displayName)
                .bfHeading(theme: theme, size: 28, relativeTo: .title)

            HStack(spacing: 12) {
                Label(exercise.displayCategory.rawValue, systemImage: categoryIcon)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(categoryColor)

                if !exercise.muscleGroups.isEmpty {
                    Text("•")
                        .foregroundStyle(.secondary)

                    Text(exercise.muscleGroups.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Quick Action Buttons

    private var quickActionButtons: some View {
        HStack(spacing: 12) {
            quickActionButton(
                icon: "clock.arrow.circlepath",
                label: "History",
                color: .blue
            ) {
                // Show history
            }

            quickActionButton(
                icon: "arrow.triangle.2.circlepath",
                label: "Replace",
                color: .orange
            ) {
                dismiss()
                onReplace()
            }

            quickActionButton(
                icon: "link",
                label: "Superset",
                color: .purple
            ) {
                dismiss()
                onSuperset()
            }

            quickActionButton(
                icon: "trash",
                label: "Delete",
                color: .red
            ) {
                dismiss()
                onDelete()
            }
        }
    }

    private func quickActionButton(
        icon: String,
        label: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(color)
                }

                Text(label)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sets Adjustment Section

    private var setsAdjustmentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Adjust Sets")
                .bfHeading(theme: theme, size: 18, relativeTo: .headline)

            // Sets stepper
            HStack {
                Text("Sets")
                    .font(.subheadline.weight(.medium))

                Spacer()

                HStack(spacing: 12) {
                    Button {
                        if sets > 1 { sets -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(sets > 1 ? theme.accent : .secondary)
                    }
                    .disabled(sets <= 1)

                    Text("\(sets)")
                        .font(.title3.weight(.bold).monospacedDigit())
                        .frame(minWidth: 30)

                    Button {
                        if sets < 10 { sets += 1 }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(sets < 10 ? theme.accent : .secondary)
                    }
                    .disabled(sets >= 10)
                }
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.regularMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(theme.cardStroke, lineWidth: 1)
                    }
            }

            // Reps input
            HStack {
                Text("Reps")
                    .font(.subheadline.weight(.medium))

                Spacer()

                TextField("8-12", text: $reps)
                    .font(.title3.weight(.bold).monospacedDigit())
                    .multilineTextAlignment(.center)
                    .frame(width: 80)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(theme.cardBackground)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(theme.cardStroke, lineWidth: 1)
                            }
                    }
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.regularMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(theme.cardStroke, lineWidth: 1)
                    }
            }

            // Weight input
            HStack {
                Text("Weight")
                    .font(.subheadline.weight(.medium))

                Spacer()

                HStack(spacing: 8) {
                    Button {
                        let increment: Double = currentUnit == .lbs ? 5 : 2.5
                        if weight >= increment { weight -= increment }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(weight > 0 ? theme.accent : .secondary)
                    }
                    .disabled(weight <= 0)

                    Text(currentUnit.format(weight))
                        .font(.title3.weight(.bold).monospacedDigit())
                        .frame(minWidth: 70)

                    Button {
                        let increment: Double = currentUnit == .lbs ? 5 : 2.5
                        weight += increment
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(theme.accent)
                    }
                }
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.regularMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(theme.cardStroke, lineWidth: 1)
                    }
            }
        }
    }

    // MARK: - Weight Unit Section

    private var weightUnitSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weight Unit")
                .bfHeading(theme: theme, size: 18, relativeTo: .headline)

            Text("This setting applies globally to all exercises")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 0) {
                ForEach(WeightUnitSetting.allCases, id: \.self) { unit in
                    Button {
                        withAnimation(.spring(response: 0.2)) {
                            // Convert weight when switching units
                            if currentUnit != unit {
                                weight = unit.convert(weight, from: currentUnit)
                            }
                            weightUnit = unit.rawValue
                        }
                    } label: {
                        Text(unit.rawValue.uppercased())
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(currentUnit == unit ? .white : .secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background {
                                if currentUnit == unit {
                                    Capsule()
                                        .fill(theme.accent)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(Capsule().fill(.regularMaterial))
            .overlay(Capsule().stroke(theme.cardStroke, lineWidth: 1))
        }
    }

    // MARK: - Helpers

    private var gradientColors: [Color] {
        switch exercise.displayCategory {
        case .push: return [.blue, .cyan]
        case .pull: return [.purple, .pink]
        case .legs: return [.orange, .yellow]
        case .core: return [.yellow, .orange]
        case .cardio: return [.red, .orange]
        case .compound: return [.green, .teal]
        case .all: return [.gray, .secondary]
        }
    }

    private var categoryIcon: String {
        switch exercise.displayCategory {
        case .push: return "arrow.up.circle"
        case .pull: return "arrow.down.circle"
        case .legs: return "figure.walk"
        case .core: return "circle.hexagongrid"
        case .cardio: return "heart"
        case .compound: return "dumbbell"
        case .all: return "figure.mixed.cardio"
        }
    }

    private var categoryColor: Color {
        switch exercise.displayCategory {
        case .push: return .blue
        case .pull: return .purple
        case .legs: return .orange
        case .core: return .yellow
        case .cardio: return .red
        case .compound: return theme.accent
        case .all: return .gray
        }
    }

    private func saveChanges() {
        let weightString = weight > 0 ? "\(Int(weight)) \(currentUnit.rawValue)" : nil
        let updated = PlannedExercise(
            id: exercise.id,
            name: exercise.name,
            category: exercise.category,
            sets: sets,
            reps: reps,
            targetWeight: weightString,
            muscleGroups: exercise.muscleGroups
        )
        onUpdate(updated)
        dismiss()
    }
}

#Preview {
    ExerciseDetailSheet(
        exercise: PlannedExercise(
            name: "Bench Press",
            category: .push,
            sets: 4,
            reps: "8-12",
            targetWeight: "135 lbs",
            muscleGroups: ["Chest", "Triceps"]
        ),
        theme: .forest,
        onDelete: {},
        onReplace: {},
        onSuperset: {},
        onUpdate: { _ in }
    )
}
