import BetterFit
import SwiftUI

// MARK: - Drafts (keeps fields editable while typing)

extension ActiveSessionView {

    func draftKey(we: WorkoutExercise, index: Int, kind: String) -> String {
        "\(we.id.uuidString)-\(index)-\(kind)"
    }

    func syncDraftsFromModel(we: WorkoutExercise) {
        let total = setCount(for: we)
        for setIdx in 0..<total {
            let pair = setValues(for: we, index: setIdx)
            // Don't overwrite the field the user is actively typing in.
            if focusedField != .setLoad(setIdx) {
                draftLoad[draftKey(we: we, index: setIdx, kind: "load")] = BFFormat.trimmed(pair.load)
            }
            if focusedField != .setReps(setIdx) {
                draftReps[draftKey(we: we, index: setIdx, kind: "reps")] = "\(pair.reps)"
            }
        }
        let current = setValues(for: we, index: setIndex)
        if focusedField != .headerLoad {
            draftLoad[draftKey(we: we, index: -1, kind: "load")] = BFFormat.trimmed(current.load)
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

    // MARK: - Draft bindings

    func headerLoadDraft(for we: WorkoutExercise) -> Binding<String> {
        let key = draftKey(we: we, index: -1, kind: "load")
        return Binding(
            get: { draftLoad[key] ?? BFFormat.trimmed(setValues(for: we, index: setIndex).load) },
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
            get: { draftLoad[key] ?? BFFormat.trimmed(setValues(for: we, index: index).load) },
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

    // MARK: - Commit

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

    func commitFocusedField() {
        guard let we = current else { return }
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

    func commitAllDraftsIfPossible() {
        guard let we = current else { return }
        commitAllDrafts(we: we)
    }
}
