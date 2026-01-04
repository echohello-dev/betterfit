import BetterFit
import SwiftUI

// MARK: - Add Exercise Sheet

/// A sheet for adding a new exercise to a workout
struct AddExerciseSheet: View {
    let theme: AppTheme
    let onAdd: (PlannedExercise) -> Void

    @State private var searchText = ""
    @State private var selectedExercise: ExerciseTemplate?
    @State private var sets: Int = 4
    @State private var reps: String = "10"
    @State private var targetWeight: String = ""

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    if selectedExercise == nil {
                        exerciseListView
                    } else {
                        exerciseConfigView
                    }
                }
            }
            .navigationTitle(selectedExercise == nil ? "Add Exercise" : "Configure")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search exercises"
            )
        }
    }

    // MARK: - Exercise List View

    private var exerciseListView: some View {
        List {
            ForEach(ExerciseTemplateCategory.allCases, id: \.self) { category in
                let exercises = filteredExercises(for: category)
                if !exercises.isEmpty {
                    Section(header: Text(category.rawValue).foregroundStyle(.secondary)) {
                        ForEach(exercises) { exercise in
                            exerciseRow(exercise)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func exerciseRow(_ exercise: ExerciseTemplate) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedExercise = exercise
            }
        } label: {
            HStack(spacing: 12) {
                // Category icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: gradientColors(for: exercise.category),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)

                    Image(systemName: categoryIcon(for: exercise.category))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(exercise.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    // MARK: - Exercise Config View

    private var exerciseConfigView: some View {
        VStack(spacing: 24) {
            // Back button
            HStack {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedExercise = nil
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.accent)
                }

                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)

            if let exercise = selectedExercise {
                // Exercise header
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: gradientColors(for: exercise.category),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 72, height: 72)

                        Image(systemName: categoryIcon(for: exercise.category))
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                    }

                    Text(exercise.name)
                        .font(.title2.weight(.bold))

                    Text(exercise.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom)

                // Configuration
                VStack(spacing: 20) {
                    setsSection
                    repsSection
                    weightSection
                }
                .padding(.horizontal)
            }

            Spacer()

            // Add button
            Button {
                addExercise()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Exercise")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Capsule().fill(theme.accent))
                .foregroundStyle(.white)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    // MARK: - Configuration Sections

    private var setsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sets")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Button {
                    if sets > 1 { sets -= 1 }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(sets > 1 ? theme.accent : .secondary)
                }
                .disabled(sets <= 1)

                Text("\(sets)")
                    .font(.title.weight(.bold))
                    .monospacedDigit()
                    .frame(minWidth: 40)

                Button {
                    if sets < 10 { sets += 1 }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(sets < 10 ? theme.accent : .secondary)
                }
                .disabled(sets >= 10)

                Spacer()
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(.regularMaterial))
    }

    private var repsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reps")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField("e.g., 8-10", text: $reps)
                .font(.title3.weight(.semibold))
                .keyboardType(.numbersAndPunctuation)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(theme.cardBackground))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(theme.cardStroke, lineWidth: 1))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(.regularMaterial))
    }

    private var weightSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Target Weight (optional)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField("e.g., 135 lbs", text: $targetWeight)
                .font(.title3.weight(.semibold))
                .keyboardType(.numbersAndPunctuation)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(theme.cardBackground))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(theme.cardStroke, lineWidth: 1))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(.regularMaterial))
    }

    // MARK: - Actions

    private func addExercise() {
        guard let exercise = selectedExercise else { return }

        // Map template category to exercise category
        let category: ExerciseCategory = {
            switch exercise.category {
            case .chest: return .push
            case .back: return .pull
            case .shoulders: return .push
            case .arms: return .pull
            case .legs: return .legs
            case .core: return .core
            }
        }()

        let planned = PlannedExercise(
            name: exercise.name,
            category: category,
            sets: sets,
            reps: reps,
            targetWeight: targetWeight.isEmpty ? nil : targetWeight,
            muscleGroups: [exercise.category.rawValue]
        )

        onAdd(planned)
        dismiss()
    }

    // MARK: - Helpers

    private func filteredExercises(for category: ExerciseTemplateCategory) -> [ExerciseTemplate] {
        let exercises = ExerciseTemplate.templates(for: category)
        if searchText.isEmpty {
            return exercises
        }
        return exercises.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
                || $0.subtitle.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func gradientColors(for category: ExerciseTemplateCategory) -> [Color] {
        switch category {
        case .chest: return [.blue, .cyan]
        case .back: return [.purple, .pink]
        case .shoulders: return [.orange, .yellow]
        case .arms: return [.teal, .green]
        case .legs: return [.orange, .red]
        case .core: return [.yellow, .orange]
        }
    }

    private func categoryIcon(for category: ExerciseTemplateCategory) -> String {
        switch category {
        case .chest: return "arrow.up"
        case .back: return "arrow.down"
        case .shoulders: return "figure.arms.open"
        case .arms: return "figure.strengthtraining.traditional"
        case .legs: return "figure.walk"
        case .core: return "circle.circle"
        }
    }
}

// MARK: - Preview

#Preview {
    AddExerciseSheet(theme: .midnight) { exercise in
        print("Added: \(exercise.name)")
    }
}
