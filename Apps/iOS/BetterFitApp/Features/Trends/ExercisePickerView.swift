import BetterFit
import SwiftUI

// MARK: - Exercise Category

enum ExerciseCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case push = "Push"
    case pull = "Pull"
    case legs = "Legs"
    case core = "Core"
    case cardio = "Cardio"
    case compound = "Compound"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .push: return "arrow.up.circle"
        case .pull: return "arrow.down.circle"
        case .legs: return "figure.walk"
        case .core: return "circle.hexagongrid"
        case .cardio: return "heart.circle"
        case .compound: return "square.stack.3d.up"
        }
    }
}

// MARK: - Exercise Sort Option

enum ExerciseSortOption: String, CaseIterable {
    case mostUsed = "Most Used"
    case alphabetical = "A-Z"
    case recentlyAdded = "Recently Added"
}

// MARK: - Selectable Exercise

struct SelectableExercise: Identifiable, Equatable {
    let id: UUID
    let name: String
    let category: ExerciseCategory
    let muscleGroups: [String]
    let usageCount: Int
    var isSelected: Bool = false

    static func == (lhs: SelectableExercise, rhs: SelectableExercise) -> Bool {
        lhs.id == rhs.id && lhs.isSelected == rhs.isSelected
    }
}

// MARK: - Exercise Picker View

struct ExercisePickerView: View {
    let theme: AppTheme
    let onAdd: ([SelectableExercise]) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var selectedCategory: ExerciseCategory = .all
    @State private var sortOption: ExerciseSortOption = .mostUsed
    @State private var exercises: [SelectableExercise] = []
    @State private var showSortOptions = false

    private var selectedCount: Int {
        exercises.filter(\.isSelected).count
    }

    private var filteredExercises: [SelectableExercise] {
        var result = exercises

        // Filter by category
        if selectedCategory != .all {
            result = result.filter { $0.category == selectedCategory }
        }

        // Filter by search
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
                    || $0.muscleGroups.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }

        // Sort
        switch sortOption {
        case .mostUsed:
            result.sort { $0.usageCount > $1.usageCount }
        case .alphabetical:
            result.sort { $0.name < $1.name }
        case .recentlyAdded:
            // For demo, just reverse order
            result.reverse()
        }

        return result
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Tab Bar
                categoryTabBar

                // Exercise List
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredExercises) { exercise in
                            exerciseRow(exercise)
                        }
                    }
                    .padding(16)
                }
            }
            .background(theme.backgroundGradient.ignoresSafeArea())
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Add Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSortOptions = true
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                addButton
            }
            .confirmationDialog("Sort By", isPresented: $showSortOptions, titleVisibility: .visible)
            {
                ForEach(ExerciseSortOption.allCases, id: \.self) { option in
                    Button(option.rawValue) {
                        sortOption = option
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .onAppear {
                loadExercises()
            }
        }
    }

    // MARK: - Category Tab Bar

    private var categoryTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ExerciseCategory.allCases) { category in
                    categoryPill(category)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private func categoryPill(_ category: ExerciseCategory) -> some View {
        let isSelected = selectedCategory == category

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.subheadline.weight(.semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                if isSelected {
                    Capsule()
                        .fill(theme.accent)
                } else {
                    Capsule()
                        .fill(.regularMaterial)
                }
            }
            .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Exercise Row

    @ViewBuilder
    private func exerciseRow(_ exercise: SelectableExercise) -> some View {
        let isSelected = exercise.isSelected

        Button {
            toggleSelection(exercise)
        } label: {
            HStack(spacing: 14) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(
                            isSelected ? theme.accent : Color.secondary.opacity(0.5), lineWidth: 2
                        )
                        .frame(width: 24, height: 24)

                    if isSelected {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(theme.accent)
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    HStack(spacing: 6) {
                        Text(exercise.muscleGroups.joined(separator: ", "))
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if exercise.usageCount > 0 {
                            Text("•")
                                .foregroundStyle(.secondary)
                            Text("\(exercise.usageCount) times")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer(minLength: 0)

                // Category badge
                Text(exercise.category.rawValue)
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(theme.accent.opacity(0.2)))
                    .foregroundStyle(theme.accent)
            }
            .padding(14)
            .background {
                let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)
                shape
                    .fill(.regularMaterial)
                    .overlay {
                        shape.stroke(
                            isSelected ? theme.accent : theme.cardStroke,
                            lineWidth: isSelected ? 2 : 1
                        )
                    }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Add Button

    @ViewBuilder
    private var addButton: some View {
        let shape = RoundedRectangle(cornerRadius: 27, style: .continuous)

        Button {
            let selected = exercises.filter(\.isSelected)
            onAdd(selected)
            dismiss()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.body.weight(.semibold))

                Text(
                    selectedCount > 0
                        ? "Add \(selectedCount) Exercise\(selectedCount > 1 ? "s" : "")"
                        : "Select Exercises"
                )
                .font(.body.weight(.semibold))
            }
            .foregroundStyle(selectedCount > 0 ? .black : .secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background {
                if #available(iOS 26.0, *) {
                    shape
                        .fill(selectedCount > 0 ? theme.accent : Color.gray.opacity(0.3))
                        .glassEffect(.regular.interactive(), in: shape)
                } else {
                    shape
                        .fill(selectedCount > 0 ? theme.accent : Color.gray.opacity(0.3))
                        .shadow(color: Color.black.opacity(0.22), radius: 14, x: 0, y: 6)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(selectedCount == 0)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Helpers

    private func toggleSelection(_ exercise: SelectableExercise) {
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            exercises[index].isSelected.toggle()
        }
    }

    private func loadExercises() {
        // Demo exercises
        exercises = [
            SelectableExercise(
                id: UUID(), name: "Bench Press", category: .push,
                muscleGroups: ["Chest", "Triceps"], usageCount: 24),
            SelectableExercise(
                id: UUID(), name: "Incline Dumbbell Press", category: .push,
                muscleGroups: ["Upper Chest", "Shoulders"], usageCount: 18),
            SelectableExercise(
                id: UUID(), name: "Overhead Press", category: .push,
                muscleGroups: ["Shoulders", "Triceps"], usageCount: 15),
            SelectableExercise(
                id: UUID(), name: "Tricep Dips", category: .push,
                muscleGroups: ["Triceps", "Chest"], usageCount: 12),
            SelectableExercise(
                id: UUID(), name: "Push-ups", category: .push, muscleGroups: ["Chest", "Triceps"],
                usageCount: 8),

            SelectableExercise(
                id: UUID(), name: "Deadlift", category: .pull,
                muscleGroups: ["Back", "Hamstrings"], usageCount: 22),
            SelectableExercise(
                id: UUID(), name: "Pull-ups", category: .pull, muscleGroups: ["Lats", "Biceps"],
                usageCount: 20),
            SelectableExercise(
                id: UUID(), name: "Barbell Row", category: .pull, muscleGroups: ["Back", "Biceps"],
                usageCount: 16),
            SelectableExercise(
                id: UUID(), name: "Lat Pulldown", category: .pull, muscleGroups: ["Lats"],
                usageCount: 14),
            SelectableExercise(
                id: UUID(), name: "Face Pulls", category: .pull,
                muscleGroups: ["Rear Delts", "Traps"], usageCount: 10),

            SelectableExercise(
                id: UUID(), name: "Squat", category: .legs, muscleGroups: ["Quads", "Glutes"],
                usageCount: 26),
            SelectableExercise(
                id: UUID(), name: "Romanian Deadlift", category: .legs,
                muscleGroups: ["Hamstrings", "Glutes"], usageCount: 18),
            SelectableExercise(
                id: UUID(), name: "Leg Press", category: .legs, muscleGroups: ["Quads", "Glutes"],
                usageCount: 14),
            SelectableExercise(
                id: UUID(), name: "Lunges", category: .legs, muscleGroups: ["Quads", "Glutes"],
                usageCount: 12),
            SelectableExercise(
                id: UUID(), name: "Calf Raises", category: .legs, muscleGroups: ["Calves"],
                usageCount: 8),

            SelectableExercise(
                id: UUID(), name: "Plank", category: .core, muscleGroups: ["Core"], usageCount: 16),
            SelectableExercise(
                id: UUID(), name: "Cable Crunches", category: .core, muscleGroups: ["Abs"],
                usageCount: 10),
            SelectableExercise(
                id: UUID(), name: "Hanging Leg Raises", category: .core,
                muscleGroups: ["Lower Abs"], usageCount: 8),

            SelectableExercise(
                id: UUID(), name: "Running", category: .cardio, muscleGroups: ["Cardio"],
                usageCount: 12),
            SelectableExercise(
                id: UUID(), name: "Rowing Machine", category: .cardio,
                muscleGroups: ["Cardio", "Back"], usageCount: 6),

            SelectableExercise(
                id: UUID(), name: "Clean and Press", category: .compound,
                muscleGroups: ["Full Body"], usageCount: 4),
            SelectableExercise(
                id: UUID(), name: "Thrusters", category: .compound, muscleGroups: ["Full Body"],
                usageCount: 3),
        ]
    }
}

#Preview {
    ExercisePickerView(theme: .forest) { exercises in
        print("Added: \(exercises.map(\.name))")
    }
}
