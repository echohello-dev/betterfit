import BetterFit
import SwiftUI
#if canImport(UIKit)
    import UIKit
#endif

// MARK: - Actions

extension ActiveSessionView {

    // MARK: - Session lifecycle

    func bootstrap() {
        startedAt = workout?.date ?? Date()
        // New workout session → wipe kg/reps overrides so this session's
        // numbers don't bleed in from a previous workout.
        if sessionWorkoutID != workout?.id {
            sessionWorkoutID = workout?.id
            setOverrides = [:]
            draftLoad = [:]
            draftReps = [:]
            completedSetIndexes = [:]
            exerciseIndex = 0
            setIndex = 0
        }
        // Capture working order once so the user can reorder freely.
        if orderedIDs.isEmpty {
            orderedIDs = (workout?.exercises ?? []).map(\.id)
        } else {
            // Make sure any new exercises added since last time are picked up.
            for id in (workout?.exercises ?? []).map(\.id) where !orderedIDs.contains(id) {
                orderedIDs.append(id)
            }
        }
        // Mirror shared superset links into local state so the session sees them.
        supersetGroup = BFSupersetStore.shared.snapshot()
        if let we = current {
            loadDefaults(for: we)
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            tick.toggle()
        }
    }

    // MARK: - Navigation

    func advanceExercise() {
        ensureOrderSeeded()
        // Next incomplete exercise after the current one (supports out-of-order).
        let start = exerciseIndex + 1
        if let next = (start..<exercises.count).first(where: {
            loggedCount(for: exercises[$0]) < setCount(for: exercises[$0])
        }) {
            jumpTo(next)
            return
        }
        // Wrap: any incomplete earlier in the list.
        if let next = (0..<exerciseIndex).first(where: {
            loggedCount(for: exercises[$0]) < setCount(for: exercises[$0])
        }) {
            jumpTo(next)
            return
        }
        // Everything logged.
        showFinish = true
    }

    func jumpTo(_ index: Int) {
        guard exercises.indices.contains(index) else { return }
        commitAllDraftsIfPossible()
        exerciseIndex = index
        let we = exercises[index]
        setIndex = (0..<setCount(for: we)).first(where: { !isSetCompleted(we: we, index: $0) })
            ?? setCount(for: we)
        loadDefaults(for: we)
        stopRest()
    }

    // MARK: - Rest

    func startRest() {
        remaining = preferredRest
        resting = true
        restTimer?.invalidate()
        restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remaining <= 1 {
                stopRest()
            } else {
                remaining -= 1
            }
        }
    }

    func stopRest() {
        resting = false
        restTimer?.invalidate()
        restTimer = nil
        remaining = preferredRest
    }

    // MARK: - Finish

    func finish() {
        let duration = Date().timeIntervalSince(startedAt)
        var summary = WorkoutSummaryData(
            name: workout?.name ?? "Session",
            duration: duration,
            exercises: exercises.map { we in
                let done = loggedCount(for: we)
                let pairs = setOverrides[we.id] ?? defaultSets(for: we)
                let best = pairs.prefix(max(done, 1)).max(by: { $0.load < $1.load })
                let vol = pairs.prefix(done).reduce(0.0) { $0 + $1.load * Double($1.reps) }
                return WorkoutSummaryExercise(
                    name: we.exercise.name,
                    best: best.map { "\(BFFormat.trimmed($0.load)) kg × \($0.reps)" } ?? "—",
                    setsDone: done,
                    setsPlanned: setCount(for: we),
                    volume: vol,
                    isPR: false
                )
            }
        )
        summary.volume = summary.exercises.reduce(0) { $0 + $1.volume }
        summary.sets = summary.exercises.reduce(0) { $0 + $1.setsDone }
        // Captured here, before `onEnd()` completes the workout and records it
        // in the recovery map, so "from" reflects the pre-workout state.
        summary.recoveryEffects = sessionRecoveryEffects()

        onFinishedSummary?(summary)
        onEnd()
        closeSession()
    }

    func closeSession() {
        if let onClose {
            onClose()
        } else {
            dismiss()
        }
    }

    // MARK: - Recovery effects

    /// Readiness change this session will cause per trained region.
    ///
    /// "From" is the live recovery state (`bodyMapManager.getRecoveryStatus`);
    /// "to" applies the same `RecoveryStatus.afterWorkout()` step that
    /// `BodyMapRecovery.recordWorkout` runs when the workout is completed.
    /// Percentages reuse RecoveryView's mapping (`RecoveryStatus.bfReadiness`).
    /// Returns `[]` when recovery data is unavailable — the summary hides the
    /// section rather than showing invented numbers.
    func sessionRecoveryEffects() -> [(muscle: String, from: Int, to: Int)] {
        guard let bodyMap = betterFit?.bodyMapManager else { return [] }
        return trainedRegions().map { region in
            let before = bodyMap.getRecoveryStatus(for: region)
            let after = before.afterWorkout()
            return (
                muscle: region.rawValue.capitalized,
                from: Int((before.bfReadiness * 100).rounded()),
                to: Int((after.bfReadiness * 100).rounded())
            )
        }
    }

    /// Distinct body regions with at least one logged set, in first-hit order.
    func trainedRegions() -> [BodyRegion] {
        var seen: Set<BodyRegion> = []
        var ordered: [BodyRegion] = []
        for item in exercises where loggedCount(for: item) > 0 {
            for group in item.exercise.muscleGroups {
                guard let region = BodyRegion(rawValue: group.bodyMapRegion), region != .other else { continue }
                if seen.insert(region).inserted {
                    ordered.append(region)
                }
            }
        }
        return ordered
    }

    // MARK: - Session composition

    func addExercise(_ planned: PlannedExercise) {
        guard var updatedWorkout = workout else { return }
        let repsVal = Int(planned.reps.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 10
        let weightVal = Double(planned.targetWeight?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined() ?? "0") ?? 0
        let sets = (0..<planned.sets).map { _ in ExerciseSet(reps: repsVal, weight: weightVal) }
        let exercise = Exercise(
            name: planned.name,
            equipmentRequired: .other,
            muscleGroups: planned.muscleGroups.compactMap { MuscleGroup(rawValue: $0.lowercased()) }
        )
        let we = WorkoutExercise(exercise: exercise, sets: sets)
        updatedWorkout.exercises.append(we)
        betterFit?.updateActiveWorkout(updatedWorkout)
        ensureOrderSeeded()
        if !orderedIDs.contains(we.id) {
            orderedIDs.append(we.id)
        }
    }

    // MARK: - Helpers

    func setCount(for we: WorkoutExercise) -> Int {
        max(setOverrides[we.id]?.count ?? we.sets.count, 1)
    }

    func loggedCount(for we: WorkoutExercise) -> Int {
        if let local = completedSetIndexes[we.id] {
            return local.count
        }
        return we.sets.filter(\.isCompleted).count
    }

    func isSetCompleted(we: WorkoutExercise, index: Int) -> Bool {
        if let local = completedSetIndexes[we.id] {
            return local.contains(index)
        }
        guard we.sets.indices.contains(index) else { return false }
        return we.sets[index].isCompleted
    }

    func defaultSets(for we: WorkoutExercise) -> [(load: Double, reps: Int)] {
        if we.sets.isEmpty {
            return [(60, 8), (60, 8), (60, 8)]
        }
        // Prefer first non-zero weight as a fill-in so empty optionals don't zero the session.
        let fallbackLoad = we.sets.compactMap(\.weight).first(where: { $0 > 0 }) ?? 0
        let fallbackReps = we.sets.first(where: { $0.reps > 0 })?.reps ?? 8
        return we.sets.map { set in
            (set.weight ?? fallbackLoad, set.reps > 0 ? set.reps : fallbackReps)
        }
    }

    func setValues(for we: WorkoutExercise, index: Int) -> (load: Double, reps: Int) {
        let pairs = setOverrides[we.id] ?? defaultSets(for: we)
        if pairs.indices.contains(index) { return pairs[index] }
        return pairs.last ?? (60, 8)
    }
}
