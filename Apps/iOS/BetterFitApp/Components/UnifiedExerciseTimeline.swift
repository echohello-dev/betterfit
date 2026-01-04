import BetterFit
import SwiftUI

// MARK: - Unified Exercise Timeline

/// A unified timeline view that works across Plan, Workout, and Active Workout views
/// Uses native SwiftUI List with swipe actions and drag-to-reorder for best UX
struct UnifiedExerciseTimeline<E: ExerciseDisplayable>: View {
    let exercises: [E]
    let selectedIndex: Int?
    let theme: AppTheme
    let weightUnit: WeightUnit
    let showHeader: Bool
    let headerTitle: String
    let onSelect: (Int) -> Void
    let onDelete: (Int) -> Void
    let onReplace: ((Int) -> Void)?
    let onSuperset: ((Int) -> Void)?
    let onComplete: ((Int) -> Void)?
    let onMove: ((IndexSet, Int) -> Void)?
    let onAdd: (() -> Void)?
    let onAdjustSets: ((Int) -> Void)?

    init(
        exercises: [E],
        selectedIndex: Int? = nil,
        theme: AppTheme,
        weightUnit: WeightUnit = .lbs,
        showHeader: Bool = false,
        headerTitle: String = "Exercises",
        onSelect: @escaping (Int) -> Void,
        onDelete: @escaping (Int) -> Void,
        onReplace: ((Int) -> Void)? = nil,
        onSuperset: ((Int) -> Void)? = nil,
        onComplete: ((Int) -> Void)? = nil,
        onMove: ((IndexSet, Int) -> Void)? = nil,
        onAdd: (() -> Void)? = nil,
        onAdjustSets: ((Int) -> Void)? = nil
    ) {
        self.exercises = exercises
        self.selectedIndex = selectedIndex
        self.theme = theme
        self.weightUnit = weightUnit
        self.showHeader = showHeader
        self.headerTitle = headerTitle
        self.onSelect = onSelect
        self.onDelete = onDelete
        self.onReplace = onReplace
        self.onSuperset = onSuperset
        self.onComplete = onComplete
        self.onMove = onMove
        self.onAdd = onAdd
        self.onAdjustSets = onAdjustSets
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Optional header
            if showHeader {
                headerRow
            }

            // Timeline list
            timelineContent
        }
    }

    // MARK: - Header Row

    private var headerRow: some View {
        HStack {
            Text(headerTitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            Spacer()

            Text("\(exercises.count) exercises")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let addAction = onAdd {
                Button(action: addAction) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(theme.accent)
                }
            }
        }
    }

    // MARK: - Timeline Content

    @ViewBuilder
    private var timelineContent: some View {
        if exercises.isEmpty {
            emptyState
        } else {
            exerciseList
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(theme.accent.opacity(0.5))

            Text("No exercises yet")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            if let addAction = onAdd {
                Button(action: addAction) {
                    Text("Add Exercise")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(theme.accent))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var exerciseList: some View {
        List {
            ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                TimelineExerciseRow(
                    exercise: exercise,
                    index: index,
                    isSelected: selectedIndex == index,
                    isFirst: index == 0,
                    isLast: index == exercises.count - 1,
                    theme: theme,
                    weightUnit: weightUnit,
                    onTap: { onSelect(index) },
                    onComplete: onComplete.map { action in { action(index) } }
                )
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        onDelete(index)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }

                    if let adjustSetsAction = onAdjustSets {
                        Button {
                            adjustSetsAction(index)
                        } label: {
                            Label("Adjust Sets", systemImage: "slider.horizontal.3")
                        }
                        .tint(.blue)
                    }

                    if let replaceAction = onReplace {
                        Button {
                            replaceAction(index)
                        } label: {
                            Label("Replace", systemImage: "arrow.triangle.2.circlepath")
                        }
                        .tint(.orange)
                    }

                    if let supersetAction = onSuperset {
                        Button {
                            supersetAction(index)
                        } label: {
                            Label("Superset", systemImage: "link")
                        }
                        .tint(.purple)
                    }
                }
                .contextMenu {
                    if let completeAction = onComplete {
                        Button {
                            completeAction(index)
                        } label: {
                            Label(
                                exercise.isCompleted ? "Mark Incomplete" : "Mark Complete",
                                systemImage: exercise.isCompleted
                                    ? "xmark.circle" : "checkmark.circle"
                            )
                        }
                    }

                    if let adjustSetsAction = onAdjustSets {
                        Button {
                            adjustSetsAction(index)
                        } label: {
                            Label("Adjust Sets", systemImage: "slider.horizontal.3")
                        }
                    }

                    if let replaceAction = onReplace {
                        Button {
                            replaceAction(index)
                        } label: {
                            Label("Replace Exercise", systemImage: "arrow.triangle.2.circlepath")
                        }
                    }

                    if let supersetAction = onSuperset {
                        Button {
                            supersetAction(index)
                        } label: {
                            Label("Create Superset", systemImage: "link")
                        }
                    }

                    Divider()

                    Button(role: .destructive) {
                        onDelete(index)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .onMove { indices, newOffset in
                onMove?(indices, newOffset)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Weight Unit

enum WeightUnit: String, CaseIterable {
    case lbs = "lbs"
    case kg = "kg"

    var multiplier: Double {
        switch self {
        case .lbs: return 1.0
        case .kg: return 0.453592
        }
    }

    func convert(_ weight: Double, from unit: WeightUnit) -> Double {
        if self == unit { return weight }
        switch (unit, self) {
        case (.lbs, .kg): return weight * 0.453592
        case (.kg, .lbs): return weight / 0.453592
        default: return weight
        }
    }

    func format(_ weight: Double) -> String {
        "\(Int(weight)) \(rawValue)"
    }
}

// MARK: - Timeline Exercise Row

private struct TimelineExerciseRow<E: ExerciseDisplayable>: View {
    let exercise: E
    let index: Int
    let isSelected: Bool
    let isFirst: Bool
    let isLast: Bool
    let theme: AppTheme
    let weightUnit: WeightUnit
    let onTap: () -> Void
    let onComplete: (() -> Void)?

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Timeline indicator (left side)
            timelineIndicator
                .frame(width: 48)

            // Exercise card
            exerciseCard
        }
        .background(theme.backgroundGradient)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("exercise-timeline-row")
    }

    // MARK: - Timeline Indicator

    private var timelineIndicator: some View {
        VStack(spacing: 0) {
            // Top line
            Rectangle()
                .fill(isFirst ? Color.clear : theme.accent.opacity(0.3))
                .frame(width: 2)

            // Circle with number
            ZStack {
                // Solid background to prevent line overlap
                Circle()
                    .fill(Color(uiColor: .systemBackground))
                    .frame(width: 32, height: 32)

                if exercise.isCompleted {
                    Circle()
                        .fill(theme.accent)
                        .frame(width: 28, height: 28)
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                } else if isSelected {
                    Circle()
                        .fill(theme.accent.opacity(0.3))
                        .frame(width: 28, height: 28)
                    Text("\(index + 1)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(theme.accent)
                    Circle()
                        .stroke(theme.accent, lineWidth: 2)
                        .frame(width: 32, height: 32)
                } else {
                    Circle()
                        .fill(theme.accent.opacity(0.15))
                        .frame(width: 28, height: 28)
                    Text("\(index + 1)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(theme.accent)
                }
            }
            .frame(width: 32, height: 32)

            // Bottom line
            Rectangle()
                .fill(isLast ? Color.clear : theme.accent.opacity(0.3))
                .frame(width: 2)
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: - Exercise Card

    private var exerciseCard: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Gradient preview thumbnail
                exercisePreviewImage
                    .frame(width: 56, height: 56)

                // Exercise info
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.displayName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(exercise.displayCategory.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                // Sets info and weight
                VStack(alignment: .trailing, spacing: 4) {
                    Text(exercise.displaySetsInfo)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    if let weight = exercise.displayWeight {
                        Text(weight)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(theme.accent)
                    }
                }

                // Category icon
                categoryIcon
                    .frame(width: 40, height: 40)
            }
            .padding(12)
            .background(cardBackground)
        }
        .buttonStyle(.plain)
        .contextMenu {
            if let completeAction = onComplete {
                Button(action: completeAction) {
                    Label(
                        exercise.isCompleted ? "Mark Incomplete" : "Mark Complete",
                        systemImage: exercise.isCompleted ? "xmark.circle" : "checkmark.circle")
                }
            }

            Divider()

            Button(role: .destructive, action: onTap) {
                Label("View Details", systemImage: "info.circle")
            }
        }
        .padding(.vertical, 6)
        .padding(.trailing, 12)
    }

    // MARK: - Exercise Preview Image (Gradient)

    private var exercisePreviewImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: categorySystemImage)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
        }
    }

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

    private var categorySystemImage: String {
        switch exercise.displayCategory {
        case .push: return "arrow.up"
        case .pull: return "arrow.down"
        case .legs: return "figure.walk"
        case .core: return "circle.circle"
        case .cardio: return "heart"
        case .compound: return "dumbbell"
        case .all: return "figure.mixed.cardio"
        }
    }

    private var categoryIcon: some View {
        ZStack {
            Circle()
                .fill(categoryColor.opacity(0.15))

            Image(systemName: categorySystemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(categoryColor)
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

    @ViewBuilder
    private var cardBackground: some View {
        let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)
        if isSelected {
            shape.fill(.regularMaterial)
            shape.stroke(theme.accent, lineWidth: 2)
        } else if exercise.isCompleted {
            shape.fill(.regularMaterial)
            shape.stroke(Color.green.opacity(0.5), lineWidth: 1)
        } else {
            shape.fill(.regularMaterial)
            shape.stroke(theme.cardStroke, lineWidth: 1)
        }
    }
}

// MARK: - Weight Unit Toggle

struct WeightUnitToggle: View {
    @Binding var unit: WeightUnit
    let theme: AppTheme

    var body: some View {
        HStack(spacing: 0) {
            ForEach(WeightUnit.allCases, id: \.self) { weightUnit in
                Button {
                    withAnimation(.spring(response: 0.2)) {
                        unit = weightUnit
                    }
                } label: {
                    Text(weightUnit.rawValue)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(unit == weightUnit ? .white : .secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background {
                            if unit == weightUnit {
                                Capsule()
                                    .fill(theme.accent)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Capsule().fill(.regularMaterial))
        .overlay(Capsule().stroke(theme.cardStroke, lineWidth: 1))
    }
}

// MARK: - Superset Indicator

struct SupersetIndicator: View {
    let exerciseCount: Int
    let roundCount: Int
    let theme: AppTheme

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "link")
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.accent)

            Text("Superset")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)

            Text("• \(exerciseCount) exercises • \(roundCount) rounds")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Menu {
                Button("Edit Superset") {}
                Button("Break Apart", role: .destructive) {}
            } label: {
                Image(systemName: "ellipsis")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(8)
            }
        }
        .padding(.horizontal, 48)
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview("Unified Timeline") {
    ScrollView {
        VStack(spacing: 0) {
            UnifiedExerciseTimeline(
                exercises: [
                    PlannedExercise(
                        name: "Deadlift", category: .pull, sets: 4, reps: "5",
                        targetWeight: "225 lbs", muscleGroups: ["Back"]),
                    PlannedExercise(
                        name: "Pull-ups", category: .pull, sets: 4, reps: "8-10",
                        muscleGroups: ["Lats"]),
                    PlannedExercise(
                        name: "Barbell Row", category: .pull, sets: 3, reps: "8",
                        targetWeight: "135 lbs", muscleGroups: ["Back"]),
                    PlannedExercise(
                        name: "Face Pulls", category: .pull, sets: 3, reps: "15",
                        targetWeight: "30 lbs", muscleGroups: ["Rear Delts"]),
                ],
                selectedIndex: 1,
                theme: .forest,
                onSelect: { _ in },
                onDelete: { _ in },
                onReplace: { _ in },
                onSuperset: { _ in },
                onComplete: { _ in }
            )
            .padding()
        }
    }
    .background(AppTheme.forest.backgroundGradient)
}
