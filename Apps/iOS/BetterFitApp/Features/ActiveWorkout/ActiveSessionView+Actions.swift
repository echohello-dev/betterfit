import BetterFit
import SwiftUI
#if canImport(UIKit)
    import UIKit
#endif

// MARK: - Actions

extension ActiveSessionView {

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

    // MARK: - Order + supersets

    func persistOrder() {
        guard var updatedWorkout = workout else { return }
        let all = updatedWorkout.exercises
        updatedWorkout.exercises = orderedIDs.compactMap { id in all.first(where: { $0.id == id }) }
        // Keep any stragglers
        let missing = all.filter { !orderedIDs.contains($0.id) }
        updatedWorkout.exercises.append(contentsOf: missing)
        betterFit?.updateActiveWorkout(updatedWorkout)
    }

    func moveExercises(from source: IndexSet, to destination: Int) {
        ensureOrderSeeded()
        let currentID = current?.id
        orderedIDs.move(fromOffsets: source, toOffset: destination)
        persistOrder()
        if let currentID, let newIdx = orderedIDs.firstIndex(of: currentID) {
            exerciseIndex = newIdx
        }
    }

    func moveExercise(from: Int, to: Int) {
        ensureOrderSeeded()
        guard exercises.indices.contains(from),
              to >= 0, to < orderedIDs.count, from != to
        else { return }
        let currentID = current?.id
        let id = orderedIDs.remove(at: from)
        orderedIDs.insert(id, at: to)
        persistOrder()
        if let currentID, let newIdx = orderedIDs.firstIndex(of: currentID) {
            exerciseIndex = newIdx
        }
    }

    func ensureOrderSeeded() {
        if orderedIDs.isEmpty {
            orderedIDs = (workout?.exercises ?? []).map(\.id)
        }
        // Sync newly added exercises
        let allIDs = (workout?.exercises ?? []).map(\.id)
        for id in allIDs where !orderedIDs.contains(id) {
            orderedIDs.append(id)
        }
        orderedIDs.removeAll { id in !allIDs.contains(id) }
    }

    func linkSuperset(_ firstIndex: Int, with secondIndex: Int) {
        ensureOrderSeeded()
        guard exercises.indices.contains(firstIndex), exercises.indices.contains(secondIndex) else { return }
        let idA = exercises[firstIndex].id
        let idB = exercises[secondIndex].id
        BFSupersetStore.shared.link(idA, idB)
        supersetGroup = BFSupersetStore.shared.snapshot()
        // Keep partners adjacent in order
        if let ia = orderedIDs.firstIndex(of: idA), let ib = orderedIDs.firstIndex(of: idB), abs(ia - ib) != 1 {
            orderedIDs.remove(at: ib)
            let insertAt = min(orderedIDs.count, ia + 1)
            orderedIDs.insert(idB, at: insertAt)
            persistOrder()
            if let cur = current?.id, let idx = orderedIDs.firstIndex(of: cur) {
                exerciseIndex = idx
            }
        }
    }

    func toggleSuperset(withNextOf id: UUID) {
        ensureOrderSeeded()
        if isSuperset(id) {
            unlinkSuperset(id)
            return
        }
        guard let idx = orderedIDs.firstIndex(of: id), idx + 1 < orderedIDs.count else { return }
        linkSuperset(idx, with: idx + 1)
    }

    func unlinkSuperset(_ id: UUID) {
        BFSupersetStore.shared.unlink(id)
        supersetGroup = BFSupersetStore.shared.snapshot()
    }

    func loadDefaults(for we: WorkoutExercise) {
        let pair = setValues(for: we, index: setIndex)
        weight = pair.load
        reps = pair.reps
        syncDraftsFromModel(we: we)
    }

    /// Update set at `index`. Copies values forward to remaining unlogged sets.
    /// Logged sets are never changed.
    func updateSet(we: WorkoutExercise, index: Int, load: Double, reps: Int) {
        guard !isSetCompleted(we: we, index: index) else { return }

        let safeLoad = load
        let safeReps = max(1, reps)

        var overrides = setOverrides[we.id] ?? defaultSets(for: we)
        let total = max(overrides.count, setCount(for: we), index + 1)
        while overrides.count < total {
            let prev = overrides.last ?? (safeLoad, safeReps)
            overrides.append(prev)
        }

        // This set + every remaining unlogged set.
        for setIdx in index..<overrides.count where !isSetCompleted(we: we, index: setIdx) {
            overrides[setIdx] = (safeLoad, safeReps)
        }
        setOverrides[we.id] = overrides

        if index == setIndex {
            weight = safeLoad
            self.reps = safeReps
        }
        syncDraftsFromModel(we: we)
    }

    /// Complete (log) a specific set via the row play button.
    func completeSet(we: WorkoutExercise, index: Int) {
        guard !isSetCompleted(we: we, index: index) else { return }
        commitAllDrafts(we: we)

        let pair = setValues(for: we, index: index)
        var load = pair.load
        var repsVal = max(1, pair.reps)
        if let raw = draftLoad[draftKey(we: we, index: index, kind: "load")],
           let parsed = parseLoad(raw, fallback: nil)
        {
            load = parsed
        }
        if let raw = draftReps[draftKey(we: we, index: index, kind: "reps")],
           let parsed = parseReps(raw, fallback: nil)
        {
            repsVal = parsed
        }

        // Don't allow logging a zeroed-out weight if we have a better known value.
        if load <= 0 {
            let fallback = defaultSets(for: we).first(where: { $0.load > 0 })?.load ?? weight
            load = fallback > 0 ? fallback : load
        }

        updateSet(we: we, index: index, load: load, reps: repsVal)
        setIndex = index
        weight = load
        reps = repsVal
        markSetCompleted(we: we, index: index, load: load, reps: repsVal)
    }

    func bumpSet(we: WorkoutExercise, loadDelta: Double, repsDelta: Int) {
        let pair = setValues(for: we, index: setIndex)
        let newLoad = max(0, (pair.load + loadDelta).rounded(toPlaces: 1))
        let newReps = max(1, pair.reps + repsDelta)
        updateSet(we: we, index: setIndex, load: newLoad, reps: newReps)
    }

    // MARK: - Draft text (keeps fields editable while typing)

    func draftKey(we: WorkoutExercise, index: Int, kind: String) -> String {
        "\(we.id.uuidString)-\(index)-\(kind)"
    }

    func syncDraftsFromModel(we: WorkoutExercise) {
        let total = setCount(for: we)
        for setIdx in 0..<total {
            let pair = setValues(for: we, index: setIdx)
            // Don't overwrite the field the user is actively typing in.
            if focusedField != .setLoad(setIdx) {
                draftLoad[draftKey(we: we, index: setIdx, kind: "load")] = formatNum(pair.load)
            }
            if focusedField != .setReps(setIdx) {
                draftReps[draftKey(we: we, index: setIdx, kind: "reps")] = "\(pair.reps)"
            }
        }
        let current = setValues(for: we, index: setIndex)
        if focusedField != .headerLoad {
            draftLoad[draftKey(we: we, index: -1, kind: "load")] = formatNum(current.load)
        }
        if focusedField != .headerReps {
            draftReps[draftKey(we: we, index: -1, kind: "reps")] = "\(current.reps)"
        }
    }

    /// Parse kg input. Empty/invalid → fallback (never invent 0 over a real value).
    func parseLoad(_ raw: String, fallback: Double?) -> Double? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return fallback }
        let cleaned = trimmed
            .replacingOccurrences(of: ",", with: ".")
            .filter { $0.isNumber || $0 == "." }
        if cleaned.isEmpty || cleaned == "." { return fallback }
        guard let value = Double(cleaned) else { return fallback }
        return max(0, value)
    }

    func parseReps(_ raw: String, fallback: Int?) -> Int? {
        let digits = raw.filter(\.isNumber)
        if digits.isEmpty { return fallback }
        return max(1, Int(digits) ?? fallback ?? 1)
    }

    func headerLoadDraft(for we: WorkoutExercise) -> Binding<String> {
        let key = draftKey(we: we, index: -1, kind: "load")
        return Binding(
            get: { draftLoad[key] ?? formatNum(setValues(for: we, index: setIndex).load) },
            set: { draftLoad[key] = $0 }
        )
    }

    func headerRepsDraft(for we: WorkoutExercise) -> Binding<String> {
        let key = draftKey(we: we, index: -1, kind: "reps")
        return Binding(
            get: { draftReps[key] ?? "\(setValues(for: we, index: setIndex).reps)" },
            set: { draftReps[key] = $0 }
        )
    }

    func setLoadDraft(we: WorkoutExercise, index: Int) -> Binding<String> {
        let key = draftKey(we: we, index: index, kind: "load")
        return Binding(
            get: { draftLoad[key] ?? formatNum(setValues(for: we, index: index).load) },
            set: { draftLoad[key] = $0 }
        )
    }

    func setRepsDraft(we: WorkoutExercise, index: Int) -> Binding<String> {
        let key = draftKey(we: we, index: index, kind: "reps")
        return Binding(
            get: { draftReps[key] ?? "\(setValues(for: we, index: index).reps)" },
            set: { draftReps[key] = $0 }
        )
    }

    func commitHeaderLoad(we: WorkoutExercise) {
        let key = draftKey(we: we, index: -1, kind: "load")
        let raw = draftLoad[key] ?? ""
        let pair = setValues(for: we, index: setIndex)
        let load = parseLoad(raw, fallback: pair.load) ?? pair.load
        updateSet(we: we, index: setIndex, load: load, reps: pair.reps)
    }

    func commitHeaderReps(we: WorkoutExercise) {
        let key = draftKey(we: we, index: -1, kind: "reps")
        let raw = draftReps[key] ?? ""
        let pair = setValues(for: we, index: setIndex)
        let value = parseReps(raw, fallback: pair.reps) ?? pair.reps
        updateSet(we: we, index: setIndex, load: pair.load, reps: value)
    }

    func commitSetLoad(we: WorkoutExercise, index: Int) {
        let key = draftKey(we: we, index: index, kind: "load")
        let raw = draftLoad[key] ?? ""
        let pair = setValues(for: we, index: index)
        let load = parseLoad(raw, fallback: pair.load) ?? pair.load
        updateSet(we: we, index: index, load: load, reps: pair.reps)
    }

    func commitSetReps(we: WorkoutExercise, index: Int) {
        let key = draftKey(we: we, index: index, kind: "reps")
        let raw = draftReps[key] ?? ""
        let pair = setValues(for: we, index: index)
        let value = parseReps(raw, fallback: pair.reps) ?? pair.reps
        updateSet(we: we, index: index, load: pair.load, reps: value)
    }

    func commitFocusedField(we: WorkoutExercise) {
        switch focusedField {
        case .headerLoad: commitHeaderLoad(we: we)
        case .headerReps: commitHeaderReps(we: we)
        case .setLoad(let setIdx): commitSetLoad(we: we, index: setIdx)
        case .setReps(let setIdx): commitSetReps(we: we, index: setIdx)
        case .none: break
        }
    }

    func commitAllDrafts(we: WorkoutExercise) {
        commitHeaderLoad(we: we)
        commitHeaderReps(we: we)
        let total = setCount(for: we)
        for setIdx in 0..<total where !isSetCompleted(we: we, index: setIdx) {
            commitSetLoad(we: we, index: setIdx)
            commitSetReps(we: we, index: setIdx)
        }
    }

    func logCurrentSet() {
        guard let we = current else { return }
        // Complete whatever set is currently selected.
        completeSet(we: we, index: setIndex)
    }

    func markSetCompleted(we: WorkoutExercise, index: Int, load: Double, reps: Int) {
        var done = completedSetIndexes[we.id] ?? []
        done.insert(index)
        completedSetIndexes[we.id] = done

        // Persist into workout model
        if var updatedWorkout = workout, let idx = updatedWorkout.exercises.firstIndex(where: { $0.id == we.id }) {
            var sets = updatedWorkout.exercises[idx].sets
            let logged = ExerciseSet(reps: reps, weight: load, isCompleted: true, timestamp: Date())
            if index < sets.count {
                sets[index] = logged
            } else {
                while sets.count < index { sets.append(ExerciseSet(reps: reps, weight: load)) }
                sets.append(logged)
            }
            updatedWorkout.exercises[idx].sets = sets
            betterFit?.updateActiveWorkout(updatedWorkout)
        }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        let completedRound = index + 1  // 1-based round number just completed

        // Superset: after logging a set, flip to the partner for the same round
        // before resting (A1 → B1 → rest → A2 → B2 …).
        if let partnerId = supersetPartner(of: we.id),
           let partnerIdx = exercises.firstIndex(where: { $0.id == partnerId })
        {
            let partner = exercises[partnerIdx]
            // Partner still needs this same set index.
            if !isSetCompleted(we: partner, index: index) {
                exerciseIndex = partnerIdx
                setIndex = index
                loadDefaults(for: partner)
                stopRest()
                return
            }
        }

        // Advance to next incomplete set on this exercise, else leave setIndex at end.
        if let nextOpen = (0..<setCount(for: we)).first(where: { !isSetCompleted(we: we, index: $0) }) {
            setIndex = nextOpen
            loadDefaults(for: we)
        }
        _ = completedRound
        startRest()
    }

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

    func commitAllDraftsIfPossible() {
        guard let we = current else { return }
        commitAllDrafts(we: we)
    }

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
                    best: best.map { "\(formatNum($0.load)) kg × \($0.reps)" } ?? "—",
                    setsDone: done,
                    setsPlanned: setCount(for: we),
                    volume: vol,
                    isPR: false
                )
            }
        )
        summary.volume = summary.exercises.reduce(0) { $0 + $1.volume }
        summary.sets = summary.exercises.reduce(0) { $0 + $1.setsDone }

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

    func addSet(to we: WorkoutExercise) {
        var overrides = setOverrides[we.id] ?? defaultSets(for: we)
        overrides.append((weight, reps))
        setOverrides[we.id] = overrides
        if var updatedWorkout = workout, let idx = updatedWorkout.exercises.firstIndex(where: { $0.id == we.id }) {
            updatedWorkout.exercises[idx].sets.append(ExerciseSet(reps: reps, weight: weight))
            betterFit?.updateActiveWorkout(updatedWorkout)
        }
    }

    func applyCurrentToAll(_ we: WorkoutExercise) {
        // Only unlogged sets from the current set onward.
        let start = (0..<setCount(for: we)).first(where: { !isSetCompleted(we: we, index: $0) }) ?? setIndex
        updateSet(we: we, index: min(start, setIndex), load: weight, reps: reps)
    }

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

    /// Clear (untick) a completed set without removing it from the list.
    func unmarkSet(we: WorkoutExercise, index: Int) {
        var done = completedSetIndexes[we.id] ?? []
        done.remove(index)
        completedSetIndexes[we.id] = done

        if var updatedWorkout = workout, let idx = updatedWorkout.exercises.firstIndex(where: { $0.id == we.id }) {
            if updatedWorkout.exercises[idx].sets.indices.contains(index) {
                updatedWorkout.exercises[idx].sets[index].isCompleted = false
            }
            betterFit?.updateActiveWorkout(updatedWorkout)
        }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // Move the cursor back to this set so the user can re-log it.
        if let current = exercises.firstIndex(where: { $0.id == we.id }) {
            exerciseIndex = current
            setIndex = index
            loadDefaults(for: we)
        }
    }

    /// Remove the set entirely from this exercise.
    func removeSet(we: WorkoutExercise, index: Int) {
        var done = completedSetIndexes[we.id] ?? []
        done.remove(index)
        completedSetIndexes[we.id] = done

        var overrides = setOverrides[we.id] ?? defaultSets(for: we)
        if overrides.indices.contains(index) {
            overrides.remove(at: index)
            setOverrides[we.id] = overrides
        }

        if var updatedWorkout = workout, let idx = updatedWorkout.exercises.firstIndex(where: { $0.id == we.id }) {
            if updatedWorkout.exercises[idx].sets.indices.contains(index) {
                updatedWorkout.exercises[idx].sets.remove(at: index)
            }
            betterFit?.updateActiveWorkout(updatedWorkout)
        }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        if let current = exercises.firstIndex(where: { $0.id == we.id }) {
            exerciseIndex = current
            let next = min(index, max(0, setCount(for: we) - 1))
            setIndex = next
            loadDefaults(for: we)
        }
        syncDraftsFromModel(we: we)
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

    func regionLabel(_ we: WorkoutExercise) -> String {
        we.exercise.muscleGroups.first?.rawValue.capitalized ?? "Lift"
    }

    func formatNum(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.1f", value)
    }
}
