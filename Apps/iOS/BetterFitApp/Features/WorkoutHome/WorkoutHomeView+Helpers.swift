import SwiftUI
import BetterFit
import Auth

// MARK: - Workout lifecycle notifications

extension Notification.Name {
    static let workoutStarted = Notification.Name("BetterFit.workoutStarted")
    static let workoutCompleted = Notification.Name("BetterFit.workoutCompleted")
    static let workoutPaused = Notification.Name("BetterFit.workoutPaused")
    static let workoutResumed = Notification.Name("BetterFit.workoutResumed")
}

// MARK: - Plan helpers (Workout tab)

extension WorkoutHomeView {
    func pairSuperset(currentIndex: Int, withIndex nextIndex: Int) {
        guard nextIndex < exercises.count, currentIndex >= 0 else { return }
        // Group both into a single workout. We use a UUID shared between the two rows.
        let group = exercises[currentIndex].id
        // Assign same supersetGroup via a side-channel via the session-model approach:
        // in this codebase we mark via `BFSupersetStore.shared`.
        BFSupersetStore.shared.link(exercises[currentIndex].id, exercises[nextIndex].id)
    }

    func removePlanExercise(_ exercise: PlannedExercise) {
        exercises.removeAll { $0.id == exercise.id }
        persistExercises()
    }

    func planInput(
        label: String,
        text: Binding<String>,
        focus: PlanField,
        keyboard: UIKeyboardType,
        onCommit: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 4) {
            TextField("—", text: text)
                .keyboardType(keyboard)
                .font(BFTypography.setValue)
                .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                .multilineTextAlignment(.trailing)
                .frame(minWidth: 56)
                .focused($focusedPlanField, equals: focus)
                .onSubmit(onCommit)
                .onChange(of: focusedPlanField) { _, newValue in
                    // Only commit on focus-loss if the user actually typed a
                    // draft. The displayed value may be a model fallback, so
                    // checking the draft directly avoids wiping stored kg.
                    guard newValue != focus else { return }
                    if hasDraft(for: focus) { onCommit() }
                }
            Text(label)
                .font(BFTypography.captionEmphasis)
                .foregroundStyle(BFColors.textTertiary(for: colorScheme))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: BFRadius.medium, style: .continuous)
                .fill(BFColors.surfaceRaised(for: colorScheme))
        )
        .overlay {
            RoundedRectangle(cornerRadius: BFRadius.medium, style: .continuous)
                .stroke(
                    focusedPlanField == focus ? BFColors.accent : BFColors.border(for: colorScheme),
                    lineWidth: focusedPlanField == focus ? 1.5 : 1
                )
        }
    }

    func hasDraft(for focus: PlanField) -> Bool {
        switch focus {
        case .weight(let id): return draftWeight[id] != nil
        case .reps(let id): return draftReps[id] != nil
        }
    }

    func weightDraft(for exercise: PlannedExercise) -> Binding<String> {
        Binding(
            get: {
                if let cached = draftWeight[exercise.id] { return cached }
                return exercise.weightValue > 0 ? BFFormat.trimmed(exercise.weightValue) : ""
            },
            set: { draftWeight[exercise.id] = $0 }
        )
    }

    func repsDraft(for exercise: PlannedExercise) -> Binding<String> {
        Binding(
            get: {
                if let cached = draftReps[exercise.id] { return cached }
                return exercise.repsValue > 0 ? "\(exercise.repsValue)" : exercise.reps
            },
            set: { draftReps[exercise.id] = $0 }
        )
    }

    func commitWeight(_ id: UUID) {
        guard let exerciseIndex = exercises.firstIndex(where: { $0.id == id }) else { return }
        let raw = draftWeight[id] ?? ""
        let cleaned = raw.replacingOccurrences(of: ",", with: ".").filter { $0.isNumber || $0 == "." }
        // Empty string clears the target weight (no zero placeholder).
        guard !cleaned.isEmpty, cleaned != ".", let value = Double(cleaned), value > 0 else {
            // Either empty or 0 — treat as "not set" and clear both draft + store.
            exercises[exerciseIndex].targetWeight = nil
            draftWeight[id] = ""
            persistExercises()
            return
        }
        exercises[exerciseIndex].targetWeight = "\(BFFormat.trimmed(value)) kg"
        draftWeight[id] = BFFormat.trimmed(value)
        persistExercises()
    }

    func commitReps(_ id: UUID) {
        guard let exerciseIndex = exercises.firstIndex(where: { $0.id == id }) else { return }
        let raw = draftReps[id] ?? ""
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            // Revert to the stored value rather than guessing.
            draftReps[id] = "\(exercises[exerciseIndex].repsValue)"
            return
        }
        // Accept only the first whole number — drop ranges like "8-10".
        let digits = trimmed.filter { $0.isNumber }
        let value = Int(digits.prefix(4)) ?? exercises[exerciseIndex].repsValue
        let stored = "\(max(1, value))"
        exercises[exerciseIndex].reps = stored
        draftReps[id] = stored
        persistExercises()
    }

    /// Exercise → SF Symbol for the work-list thumbnail tile.
    /// Name heuristics first (same convention as the historical `thumbIcon`),
    /// falling back to the shared `ExerciseCategory.icon` mapping.
    func thumbIcon(for exercise: PlannedExercise) -> String {
        let name = exercise.name.lowercased()
        if name.contains("run") || name.contains("treadmill") { return "figure.run" }
        if name.contains("bench") || name.contains("press") { return "dumbbell.fill" }
        if name.contains("row") { return "figure.strengthtraining.traditional" }
        if name.contains("yoga") { return "figure.yoga" }
        return exercise.category.icon
    }

    func meta(for exercise: PlannedExercise, index: Int, focus: Bool) -> String {
        var parts: [String] = []
        if focus { parts.append("Focus exercise") }
        if let first = exercise.muscleGroups.first {
            parts.append(first.capitalized)
        } else {
            parts.append(exercise.category.rawValue.capitalized)
        }
        return parts.joined(separator: " · ")
    }

    func replaceWorkoutPreview(_ preview: WorkoutPreview) {
        exercises = preview.exercises
        sessionName = preview.name
        if let type = workoutTypeMatching(preview.name) {
            workoutType = type
        }
        persistExercises()
    }

    func workoutTypeMatching(_ name: String) -> WorkoutType? {
        let lowered = name.lowercased()
        if lowered.contains("pull") { return .pull }
        if lowered.contains("push") { return .push }
        if lowered.contains("leg") { return .legs }
        if lowered.contains("upper") { return .upper }
        if lowered.contains("lower") { return .lower }
        if lowered.contains("condition") || lowered.contains("cardio") { return .cardio }
        if lowered.contains("full") { return .fullBody }
        return nil
    }

    func showPreview(named name: String) {
        guard let preview = previewForName(name) else { return }
        workoutPreview = preview
    }

    func previewForName(_ name: String) -> WorkoutPreview? {
        if name == sessionName {
            return WorkoutPreview(
                name: sessionName,
                duration: plannedMinutes,
                exercises: exercises
            )
        }
        return WorkoutPreviewLibrary.sampleWorkouts.first(where: { $0.name == name })
            ?? WorkoutPreview(
                name: name,
                duration: 45,
                exercises: WorkoutHomeView.demoExercises(named: name)
            )
    }

    static func demoExercises(named name: String) -> [PlannedExercise] {
        let lowered = name.lowercased()
        if lowered.contains("leg") {
            return WorkoutPreviewLibrary.sampleWorkouts.first(where: { $0.name == "Legs A" })?.exercises ?? []
        }
        if lowered.contains("push") {
            return WorkoutPreviewLibrary.sampleWorkouts.first(where: { $0.name == "Push A" })?.exercises ?? []
        }
        if lowered.contains("condition") {
            return WorkoutPreviewLibrary.sampleWorkouts.first(where: { $0.name == "Conditioning" })?.exercises ?? []
        }
        return WorkoutPreviewLibrary.sampleWorkouts.first(where: { $0.name == "Pull Day" })?.exercises ?? []
    }

    // MARK: - Data

    func loadPlan() {
        if let plan = todayPlan, !plan.isRest, !plan.exercises.isEmpty {
            exercises = plan.exercises
            workoutType = plan.workoutType
            sessionName = plan.workoutType.map { "\($0.rawValue) Day" } ?? "Today's session"
        } else if exercises.isEmpty {
            // Seed demo plan into the manager so Start workout picks it up.
            exercises = Self.demoPullDay
            workoutType = .pull
            sessionName = "Pull Day"
        }

        // Always keep planManager in sync with what Plan is showing.
        persistExercises()

        // Seed demo history once so Log/Targets have data
        if demoModeOverride ?? demoModeEnabled {
            seedLightDemoIfNeeded()
        }
    }

    func persistExercises() {
        guard let manager = planManager else { return }
        let date = Calendar.current.startOfDay(for: Date())
        let existing = manager.getPlanDay(for: date)
        manager.replaceDay(
            WorkoutPlanDay(
                id: existing?.id ?? UUID(),
                date: date,
                workoutType: workoutType ?? existing?.workoutType ?? .fullBody,
                exercises: exercises,
                isRest: exercises.isEmpty,
                isCompleted: existing?.isCompleted ?? false
            )
        )
    }

    func remove(_ exercise: PlannedExercise) {
        exercises.removeAll { $0.id == exercise.id }
        persistExercises()
    }

    func moveToTop(_ exercise: PlannedExercise) {
        guard let exerciseIndex = exercises.firstIndex(where: { $0.id == exercise.id }), exerciseIndex > 0 else { return }
        let item = exercises.remove(at: exerciseIndex)
        exercises.insert(item, at: 0)
        persistExercises()
    }

    func cycleSession() {
        let cycle: [WorkoutType] = [.pull, .push, .legs, .upper]
        let next: WorkoutType
        if let current = workoutType, let idx = cycle.firstIndex(of: current) {
            next = cycle[(idx + 1) % cycle.count]
        } else {
            next = .pull
        }
        workoutType = next
        sessionName = "\(next.rawValue) Day"
        if let manager = planManager {
            exercises = manager.getTodayPlan()?.exercises ?? Self.demoFor(next)
        } else {
            exercises = Self.demoFor(next)
        }
        if exercises.isEmpty { exercises = Self.demoFor(next) }
        persistExercises()
    }

    func adoptSession(named name: String) {
        sessionName = name
        if name.localizedCaseInsensitiveContains("leg") {
            workoutType = .legs
            exercises = Self.demoFor(.legs)
        } else if name.localizedCaseInsensitiveContains("push") {
            workoutType = .push
            exercises = Self.demoFor(.push)
        } else if name.localizedCaseInsensitiveContains("condition") {
            workoutType = .cardio
            exercises = Self.demoFor(.cardio)
        } else {
            workoutType = .pull
            exercises = Self.demoPullDay
        }
        persistExercises()
    }

    func repeatLast() {
        let history = betterFit.getWorkoutHistory().sorted { $0.date > $1.date }
        guard let last = history.first else { return }
        sessionName = last.name
        exercises = last.exercises.map { we in
            PlannedExercise(
                name: we.exercise.name,
                sets: max(we.sets.count, 3),
                reps: "\(we.sets.first?.reps ?? 8)",
                targetWeight: we.sets.first?.weight.map { "\(Int($0)) kg" },
                muscleGroups: we.exercise.muscleGroups.map(\.rawValue)
            )
        }
        persistExercises()
    }

    func trimToThirty() {
        // Keep focus lifts first, cap around 5 movements
        if exercises.count > 5 {
            exercises = Array(exercises.prefix(5))
            persistExercises()
        }
    }

    func seedLightDemoIfNeeded() {
        // Only seed if history is empty — avoid fighting real data
        guard betterFit.getWorkoutHistory().isEmpty else { return }
        let demo = Workout(
            name: "Push A",
            exercises: [
                WorkoutExercise(
                    exercise: Exercise(
                        name: "Bench press",
                        equipmentRequired: .barbell,
                        muscleGroups: [.chest, .triceps]
                    ),
                    sets: [
                        ExerciseSet(reps: 8, weight: 60, isCompleted: true),
                        ExerciseSet(reps: 8, weight: 60, isCompleted: true),
                        ExerciseSet(reps: 6, weight: 65, isCompleted: true),
                    ]
                )
            ],
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            duration: 48 * 60,
            isCompleted: true
        )
        betterFit.completeWorkout(demo)
    }

    // MARK: - Demo data

    static let demoPullDay: [PlannedExercise] = [
        PlannedExercise(name: "Lat pulldown", category: .pull, sets: 3, reps: "8", targetWeight: "50 kg", muscleGroups: ["Lats"]),
        PlannedExercise(name: "Cable row", category: .pull, sets: 4, reps: "8", targetWeight: "64 kg", muscleGroups: ["Lats"]),
        PlannedExercise(name: "Barbell curl", category: .pull, sets: 4, reps: "8", targetWeight: "30 kg", muscleGroups: ["Biceps"]),
        PlannedExercise(name: "Hammer curls", category: .pull, sets: 3, reps: "12", targetWeight: "15 kg", muscleGroups: ["Biceps"]),
        PlannedExercise(name: "Face pull", category: .pull, sets: 3, reps: "15", targetWeight: "18 kg", muscleGroups: ["Rear delts"]),
        PlannedExercise(name: "Reverse fly", category: .pull, sets: 3, reps: "12", targetWeight: "10 kg", muscleGroups: ["Rear delts"]),
        PlannedExercise(name: "Cable wood chop", category: .compound, sets: 3, reps: "15", targetWeight: "20 kg", muscleGroups: ["Core"]),
    ]

    private static func demoFor(_ type: WorkoutType) -> [PlannedExercise] {
        switch type {
        case .push:
            return [
                PlannedExercise(name: "Bench press", category: .push, sets: 4, reps: "6", targetWeight: "70 kg", muscleGroups: ["Chest"]),
                PlannedExercise(name: "Overhead press", category: .push, sets: 3, reps: "8", targetWeight: "40 kg", muscleGroups: ["Shoulders"]),
                PlannedExercise(name: "Incline dumbbell press", category: .push, sets: 3, reps: "10", targetWeight: "28 kg", muscleGroups: ["Chest"]),
                PlannedExercise(name: "Lateral raise", category: .push, sets: 3, reps: "12", targetWeight: "12 kg", muscleGroups: ["Shoulders"]),
                PlannedExercise(name: "Tricep pushdown", category: .push, sets: 3, reps: "12", targetWeight: "25 kg", muscleGroups: ["Triceps"]),
            ]
        case .legs:
            return [
                PlannedExercise(name: "Back squat", category: .legs, sets: 4, reps: "5", targetWeight: "100 kg", muscleGroups: ["Quads"]),
                PlannedExercise(name: "Romanian deadlift", category: .legs, sets: 3, reps: "8", targetWeight: "80 kg", muscleGroups: ["Hamstrings"]),
                PlannedExercise(name: "Leg press", category: .legs, sets: 3, reps: "10", targetWeight: "160 kg", muscleGroups: ["Quads"]),
                PlannedExercise(name: "Walking lunge", category: .legs, sets: 3, reps: "12", targetWeight: "20 kg", muscleGroups: ["Glutes"]),
                PlannedExercise(name: "Calf raise", category: .legs, sets: 4, reps: "15", targetWeight: "60 kg", muscleGroups: ["Calves"]),
            ]
        case .cardio:
            return [
                PlannedExercise(name: "Treadmill intervals", category: .cardio, sets: 8, reps: "1", targetWeight: nil, muscleGroups: ["Cardio"]),
                PlannedExercise(name: "Row erg", category: .cardio, sets: 4, reps: "500m", targetWeight: nil, muscleGroups: ["Cardio"]),
                PlannedExercise(name: "Core circuit", category: .compound, sets: 3, reps: "12", targetWeight: nil, muscleGroups: ["Core"]),
            ]
        default:
            return demoPullDay
        }
    }
}
