import BetterFit
import SwiftUI

// MARK: - Active Workout View

struct ActiveWorkoutView: View {
    let theme: AppTheme
    let initialExercises: [WorkoutExerciseState]
    let onComplete: () -> Void
    let onCancel: () -> Void

    @State private var exercises: [WorkoutExerciseState] = []
    @State private var selectedExerciseIndex: Int = 0
    @State private var replaceExerciseIndex: Int?
    @State private var showExercisePicker = false
    @State private var showSupersetPicker = false
    @State private var supersetTargetIndex: Int?
    @State private var elapsedTime: TimeInterval = 0
    @State private var workoutTimer: Timer?
    @State private var startTime: Date = .now
    @State private var isPaused: Bool = false
    @State private var pausedElapsedTime: TimeInterval = 0

    @Environment(\.dismiss) private var dismiss

    private var currentExercise: WorkoutExerciseState? {
        guard selectedExerciseIndex < exercises.count else { return nil }
        return exercises[selectedExerciseIndex]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundGradient.ignoresSafeArea()

                if exercises.isEmpty {
                    emptyWorkoutView
                } else {
                    workoutContent
                }
            }
            .navigationTitle("Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .principal) {
                    elapsedTimeView
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Finish") {
                        onComplete()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(exercises.isEmpty)
                }
            }
            .sheet(isPresented: $showExercisePicker) {
                ExercisePickerView(theme: theme) { selectedExercises in
                    if let replaceIndex = replaceExerciseIndex {
                        replaceExercise(selectedExercises, at: replaceIndex)
                        replaceExerciseIndex = nil
                    } else {
                        addExercises(selectedExercises)
                    }
                }
                .presentationDetents([.large])
            }
            .sheet(isPresented: $showSupersetPicker) {
                ExercisePickerView(theme: theme) { selectedExercises in
                    if let targetIndex = supersetTargetIndex {
                        addSupersetExercises(selectedExercises, at: targetIndex)
                    }
                }
                .presentationDetents([.large])
            }
            .onAppear {
                exercises = initialExercises
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
        }
    }

    // MARK: - Empty State

    private var emptyWorkoutView: some View {
        VStack(spacing: 24) {
            FitnessIcon(systemImage: "dumbbell.fill", size: 48, color: theme.accent.opacity(0.5))

            VStack(spacing: 8) {
                Text("No exercises yet")
                    .font(.title3.weight(.semibold))

                Text("Add exercises to start your workout")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button {
                showExercisePicker = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Exercises")
                }
                .font(.body.weight(.semibold))
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Capsule().fill(theme.accent))
                .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Workout Content

    private var workoutContent: some View {
        HStack(spacing: 0) {
            // Timeline sidebar
            timelineSidebar
                .frame(width: 60)

            // Main content area
            VStack(spacing: 0) {
                if let exercise = currentExercise {
                    WorkoutExerciseDetailView(
                        exercise: exercise,
                        theme: theme,
                        onUpdateSet: { setIndex, reps, weight in
                            updateSet(
                                exerciseIndex: selectedExerciseIndex,
                                setIndex: setIndex,
                                reps: reps,
                                weight: weight
                            )
                        },
                        onCompleteSet: { setIndex in
                            completeSet(exerciseIndex: selectedExerciseIndex, setIndex: setIndex)
                        },
                        onAddSet: {
                            addSet(to: selectedExerciseIndex)
                        },
                        onDeleteSet: { setIndex in
                            deleteSet(exerciseIndex: selectedExerciseIndex, setIndex: setIndex)
                        },
                        onCreateSuperset: {
                            supersetTargetIndex = selectedExerciseIndex
                            showSupersetPicker = true
                        },
                        onReplace: {
                            replaceExerciseIndex = selectedExerciseIndex
                            showExercisePicker = true
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            addExerciseButton
        }
    }

    // MARK: - Timeline Sidebar

    private var timelineSidebar: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                        timelineItem(
                            exercise: exercise, index: index, isLast: index == exercises.count - 1
                        )
                        .id(exercise.id)
                    }
                }
                .padding(.vertical, 16)
            }
            .onChange(of: selectedExerciseIndex) { _, newValue in
                if newValue < exercises.count {
                    withAnimation {
                        proxy.scrollTo(exercises[newValue].id, anchor: .center)
                    }
                }
            }
        }
        .background(Color.black.opacity(0.1))
    }

    @ViewBuilder
    private func timelineItem(exercise: WorkoutExerciseState, index: Int, isLast: Bool) -> some View
    {
        TimelineItemButton(
            index: index,
            isSelected: index == selectedExerciseIndex,
            isCompleted: exercise.isCompleted,
            prevCompleted: index > 0 ? exercises[index - 1].isCompleted : false,
            isLast: isLast,
            theme: theme
        ) {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedExerciseIndex = index
            }
        } onDelete: {
            removeExercise(at: index)
        }
    }

    // MARK: - Add Exercise Button

    private var addExerciseButton: some View {
        Button {
            showExercisePicker = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                Text("Add Exercise")
            }
            .font(.body.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(theme.accent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Elapsed Time

    private var elapsedTimeView: some View {
        HStack(spacing: 6) {
            Button {
                togglePause()
            } label: {
                Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                    .font(.subheadline)
                    .foregroundStyle(isPaused ? .green : theme.accent)
            }
            .buttonStyle(.plain)

            Text(formatElapsedTime(elapsedTime))
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .foregroundStyle(isPaused ? .orange : .primary)

            if isPaused {
                Text("Paused")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
    }

    // MARK: - Timer

    private func startTimer() {
        startTime = .now
        pausedElapsedTime = 0
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if !isPaused {
                elapsedTime = pausedElapsedTime + Date.now.timeIntervalSince(startTime)
            }
        }
    }

    private func stopTimer() {
        workoutTimer?.invalidate()
        workoutTimer = nil
    }

    private func togglePause() {
        if isPaused {
            // Resuming: reset start time, keep accumulated elapsed time
            pausedElapsedTime = elapsedTime
            startTime = .now
        }
        isPaused.toggle()
    }

    // MARK: - Actions

    private func addExercises(_ selectedExercises: [SelectableExercise]) {
        let newExercises = selectedExercises.map { selected in
            WorkoutExerciseState(
                id: UUID(),
                exercise: ExerciseDefinition(
                    id: selected.id,
                    name: selected.name,
                    category: selected.category,
                    muscleGroups: selected.muscleGroups,
                    videoURL: nil,
                    description: "Perform this exercise with controlled movement.",
                    aliases: [],
                    relatedExercises: []
                ),
                sets: [
                    WorkoutSetState(id: UUID(), reps: 10, weight: 0),
                    WorkoutSetState(id: UUID(), reps: 10, weight: 0),
                    WorkoutSetState(id: UUID(), reps: 10, weight: 0),
                ]
            )
        }
        exercises.append(contentsOf: newExercises)

        if selectedExerciseIndex >= exercises.count - newExercises.count {
            selectedExerciseIndex = exercises.count - newExercises.count
        }
    }

    private func addSupersetExercises(_ selectedExercises: [SelectableExercise], at index: Int) {
        guard index < exercises.count else { return }

        let supersetGroupId = exercises[index].supersetGroupId ?? UUID()

        // Mark current exercise as superset
        exercises[index].isSuperset = true
        exercises[index].supersetGroupId = supersetGroupId

        let newExercises = selectedExercises.map { selected in
            WorkoutExerciseState(
                id: UUID(),
                exercise: ExerciseDefinition(
                    id: selected.id,
                    name: selected.name,
                    category: selected.category,
                    muscleGroups: selected.muscleGroups,
                    videoURL: nil,
                    description: "Perform this exercise with controlled movement.",
                    aliases: [],
                    relatedExercises: []
                ),
                sets: exercises[index].sets.map { set in
                    WorkoutSetState(id: UUID(), reps: set.reps, weight: 0)
                },
                isSuperset: true,
                supersetGroupId: supersetGroupId
            )
        }

        exercises.insert(contentsOf: newExercises, at: index + 1)
    }

    private func replaceExercise(_ selectedExercises: [SelectableExercise], at index: Int) {
        guard index < exercises.count, let selected = selectedExercises.first else { return }
        let replacement = WorkoutExerciseState(
            id: UUID(),
            exercise: ExerciseDefinition(
                id: selected.id,
                name: selected.name,
                category: selected.category,
                muscleGroups: selected.muscleGroups,
                videoURL: nil,
                description: "Perform this exercise with controlled movement.",
                aliases: [],
                relatedExercises: []
            ),
            sets: [
                WorkoutSetState(id: UUID(), reps: 10, weight: 0),
                WorkoutSetState(id: UUID(), reps: 10, weight: 0),
                WorkoutSetState(id: UUID(), reps: 10, weight: 0),
            ]
        )
        exercises[index] = replacement
    }

    private func removeExercise(at index: Int) {
        guard index < exercises.count else { return }

        withAnimation {
            exercises.remove(at: index)

            if selectedExerciseIndex >= exercises.count {
                selectedExerciseIndex = max(0, exercises.count - 1)
            }
        }
    }

    private func updateSet(exerciseIndex: Int, setIndex: Int, reps: Int, weight: Double) {
        guard exerciseIndex < exercises.count,
            setIndex < exercises[exerciseIndex].sets.count
        else { return }

        exercises[exerciseIndex].sets[setIndex].reps = reps
        exercises[exerciseIndex].sets[setIndex].weight = weight
    }

    private func completeSet(exerciseIndex: Int, setIndex: Int) {
        guard exerciseIndex < exercises.count,
            setIndex < exercises[exerciseIndex].sets.count
        else { return }

        exercises[exerciseIndex].sets[setIndex].isCompleted = true

        // Auto-advance to next exercise if all sets completed
        if exercises[exerciseIndex].isCompleted && exerciseIndex < exercises.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedExerciseIndex = exerciseIndex + 1
            }
        }
    }

    private func addSet(to exerciseIndex: Int) {
        guard exerciseIndex < exercises.count else { return }

        let lastSet = exercises[exerciseIndex].sets.last
        let newSet = WorkoutSetState(
            id: UUID(),
            reps: lastSet?.reps ?? 10,
            weight: lastSet?.weight ?? 0
        )

        exercises[exerciseIndex].sets.append(newSet)
    }

    private func deleteSet(exerciseIndex: Int, setIndex: Int) {
        guard exerciseIndex < exercises.count,
            setIndex < exercises[exerciseIndex].sets.count,
            exercises[exerciseIndex].sets.count > 1
        else { return }

        exercises[exerciseIndex].sets.remove(at: setIndex)
    }

    // MARK: - Helpers

    private func formatElapsedTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Timeline Item Button

private struct TimelineItemButton: View {
    let index: Int
    let isSelected: Bool
    let isCompleted: Bool
    let prevCompleted: Bool
    let isLast: Bool
    let theme: AppTheme
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Connector line (top)
                if index > 0 {
                    Rectangle()
                        .fill(prevCompleted ? theme.accent : theme.cardStroke)
                        .frame(width: 2, height: 16)
                }

                circleIndicator

                // Connector line (bottom)
                if !isLast {
                    Rectangle()
                        .fill(isCompleted ? theme.accent : theme.cardStroke)
                        .frame(width: 2, height: 16)
                }
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Remove Exercise", systemImage: "trash")
            }
        }
    }

    @ViewBuilder
    private var circleIndicator: some View {
        ZStack {
            if isCompleted {
                Circle()
                    .fill(theme.accent)
                    .frame(width: 28, height: 28)
            } else if isSelected {
                Circle()
                    .fill(theme.accent.opacity(0.3))
                    .frame(width: 28, height: 28)
            } else {
                Circle()
                    .fill(theme.accent.opacity(0.15))
                    .frame(width: 28, height: 28)
            }

            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
            } else {
                Text("\(index + 1)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isSelected ? theme.accent : theme.accent)
            }

            if isSelected {
                Circle()
                    .stroke(theme.accent, lineWidth: 2)
                    .frame(width: 34, height: 34)
            }
        }
    }
}

#Preview {
    ActiveWorkoutView(
        theme: .forest,
        initialExercises: [
            WorkoutExerciseState(
                id: UUID(),
                exercise: ExerciseDefinition(
                    id: UUID(),
                    name: "Bench Press",
                    category: .push,
                    muscleGroups: ["Chest", "Triceps"],
                    videoURL: nil,
                    description: "Lie on a flat bench and press the barbell upward.",
                    aliases: ["Flat Bench", "Barbell Bench"],
                    relatedExercises: ["Incline Press", "Dumbbell Press"]
                ),
                sets: [
                    WorkoutSetState(id: UUID(), reps: 10, weight: 135),
                    WorkoutSetState(id: UUID(), reps: 8, weight: 155),
                    WorkoutSetState(id: UUID(), reps: 6, weight: 175),
                ]
            ),
            WorkoutExerciseState(
                id: UUID(),
                exercise: ExerciseDefinition(
                    id: UUID(),
                    name: "Incline Dumbbell Press",
                    category: .push,
                    muscleGroups: ["Upper Chest", "Shoulders"],
                    videoURL: nil,
                    description: "Press dumbbells on an incline bench.",
                    aliases: ["Incline DB Press"],
                    relatedExercises: ["Bench Press", "Shoulder Press"]
                ),
                sets: [
                    WorkoutSetState(id: UUID(), reps: 12, weight: 50),
                    WorkoutSetState(id: UUID(), reps: 10, weight: 55),
                    WorkoutSetState(id: UUID(), reps: 8, weight: 60),
                ]
            ),
        ],
        onComplete: {},
        onCancel: {}
    )
}
