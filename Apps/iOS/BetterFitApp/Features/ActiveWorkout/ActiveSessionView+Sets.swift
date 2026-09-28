import BetterFit
import SwiftUI
#if canImport(UIKit)
    import UIKit
#endif

// MARK: - Sets

extension ActiveSessionView {

    // MARK: - Sets section

    func setsSection(_ we: WorkoutExercise) -> some View {
        let total = setCount(for: we)
        let done = loggedCount(for: we)
        return VStack(alignment: .leading, spacing: 0) {
            BFSectionRule(label: "This exercise", trailing: "\(done) of \(total) logged")
            ForEach(0..<total, id: \.self) { setIdx in
                setRow(we: we, index: setIdx)
            }
            BFAddRow(label: "Add a set") { addSet(to: we) }
        }
        .padding(.horizontal, BFSpacing.pageHorizontal)
    }

    func setRow(we: WorkoutExercise, index: Int) -> some View {
        let logged = isSetCompleted(we: we, index: index)
        let isCurrent = index == setIndex && !logged
        return HStack(spacing: 10) {
            Button {
                if !logged {
                    commitAllDrafts(we: we)
                    setIndex = index
                    let pair = setValues(for: we, index: index)
                    weight = pair.load
                    reps = pair.reps
                    syncDraftsFromModel(we: we)
                }
            } label: {
                Text(String(format: "%02d", index + 1))
                    .font(BFTypography.gutter)
                    .foregroundStyle(
                        isCurrent
                            ? BFColors.accentText(for: colorScheme)
                            : BFColors.textTertiary(for: colorScheme)
                    )
                    .frame(width: 28, alignment: .leading)
            }
            .buttonStyle(.plain)

            // Editable kg
            setInputField(
                text: setLoadDraft(we: we, index: index),
                unit: "kg",
                focus: .setLoad(index),
                keyboard: .decimalPad,
                enabled: !logged,
                onCommit: { commitSetLoad(we: we, index: index) }
            )

            Text("×")
                .font(BFTypography.subheadlineEmphasis)
                .foregroundStyle(BFColors.textTertiary(for: colorScheme))

            // Editable reps
            setInputField(
                text: setRepsDraft(we: we, index: index),
                unit: nil,
                focus: .setReps(index),
                keyboard: .numberPad,
                enabled: !logged,
                onCommit: { commitSetReps(we: we, index: index) }
            )

            if logged {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(BFColors.accentText(for: colorScheme))
                    .frame(width: 44, height: 44)
            } else {
                // Play = complete/log this set
                Button {
                    completeSet(we: we, index: index)
                } label: {
                    Image(systemName: isCurrent ? "play.circle.fill" : "play.circle")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(BFColors.accent)
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Complete set \(index + 1)")
            }
        }
        .padding(.vertical, 12)
        .opacity(logged ? 0.7 : 1)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(BFColors.separator(for: colorScheme))
                .frame(height: 1)
        }
        .overlay(alignment: .leading) {
            if isCurrent {
                Rectangle()
                    .fill(BFColors.accent)
                    .frame(width: 3)
                    .offset(x: -BFSpacing.pageHorizontal)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if logged {
                // Swipe right → uncheck / clear this set
                Button {
                    unmarkSet(we: we, index: index)
                } label: {
                    Label("Untick", systemImage: "arrow.uturn.backward")
                }
                .tint(BFColors.yellowDeep)
            }
            // Swipe right → delete the set entirely
            Button(role: .destructive) {
                removeSet(we: we, index: index)
            } label: {
                Label("Remove", systemImage: "trash")
            }
        }
    }

    func setInputField(
        text: Binding<String>,
        unit: String?,
        focus: FieldFocus,
        keyboard: UIKeyboardType,
        enabled: Bool,
        onCommit: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 4) {
            TextField("0", text: text)
                .keyboardType(keyboard)
                .font(BFTypography.setValue)
                .foregroundStyle(
                    enabled
                        ? BFColors.textPrimary(for: colorScheme)
                        : BFColors.textSecondary(for: colorScheme)
                )
                .multilineTextAlignment(.trailing)
                .disabled(!enabled)
                .focused($focusedField, equals: focus)
                .onSubmit(onCommit)
                .onChange(of: focusedField) { _, newValue in
                    if newValue != focus { onCommit() }
                }
            if let unit {
                Text(unit)
                    .font(BFTypography.captionEmphasis)
                    .foregroundStyle(BFColors.textTertiary(for: colorScheme))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(minWidth: 92)
        .background(
            RoundedRectangle(cornerRadius: BFRadius.medium, style: .continuous)
                .fill(BFColors.surfaceRaised(for: colorScheme).opacity(enabled ? 1 : 0.5))
        )
        .overlay {
            RoundedRectangle(cornerRadius: BFRadius.medium, style: .continuous)
                .stroke(
                    focusedField == focus
                        ? BFColors.accent
                        : BFColors.border(for: colorScheme),
                    lineWidth: focusedField == focus ? 1.5 : 1
                )
        }
    }

    // MARK: - Set editing

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
        let newLoad = max(0, roundedToTenth(pair.load + loadDelta))
        let newReps = max(1, pair.reps + repsDelta)
        updateSet(we: we, index: setIndex, load: newLoad, reps: newReps)
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
        startRest()
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
}

// MARK: - Rounding

/// Rounds to one decimal place. Local helper so `Double` stays untouched.
private func roundedToTenth(_ value: Double) -> Double {
    (value * 10).rounded() / 10
}
