import BetterFit
import SwiftUI
#if canImport(UIKit)
    import UIKit
#endif

// MARK: - Exercise Detail Sheet
//
// Plan-mode editor for a single exercise. Lists each set as its own row with
// editable kg + reps. Users can add or remove set rows from the bottom.

struct ExerciseDetailSheet: View {
    @Environment(\.colorScheme) var colorScheme
    let exercise: PlannedExercise
    let theme: AppTheme
    let onDelete: () -> Void
    let onReplace: () -> Void
    let onSuperset: () -> Void
    let onUpdate: (PlannedExercise) -> Void

    @AppStorage(WeightUnitSetting.storageKey) private var weightUnit: String = WeightUnitSetting.lbs
        .rawValue

    @State private var setRows: [PlannedSet] = []
    /// Draft text for the in-progress field (so empty reps don't auto-become 0).
    @State private var rowLoadDraft: [Int: String] = [:]
    @State private var rowRepsDraft: [Int: String] = [:]
    @FocusState private var focusedRow: RowField?

    private enum RowField: Hashable {
        case load(Int)
        case reps(Int)
    }

    @Environment(\.dismiss) var dismiss

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
        _setRows = State(initialValue: exercise.resolvedSets())
    }

    private var currentUnit: WeightUnitSetting {
        WeightUnitSetting(rawValue: weightUnit) ?? .lbs
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    DemoVideoPlayer(
                        url: DemoVideoLibrary.videoURL(for: exercise.displayName),
                        height: 200,
                        fallbackGradient: gradientColors
                    )
                    .overlay(alignment: .topTrailing) {
                        Text("AUTO-PLAY")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(BFColors.surfaceRaised(for: colorScheme)))
                            .padding(12)
                    }

                    exerciseHeader
                    quickActionButtons
                    Divider().padding(.vertical, 4)
                    setsEditor
                    Color.clear.frame(height: 80)
                }
                .padding(20)
            }
            .bfPageBackground()
            .navigationTitle("Exercise Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .principal) {
                    Text("\(setRows.count) sets")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") { saveChanges() }.fontWeight(.semibold)
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 10) {
                    Button {
                        removeSet()
                    } label: {
                        Label("Remove set", systemImage: "minus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(setRows.count > 1 ? BFColors.textPrimary(for: colorScheme) : BFColors.textTertiary(for: colorScheme))
                            .frame(maxWidth: .infinity)
                            .frame(height: BFControlSize.buttonMedium)
                            .background(Capsule().fill(BFColors.surfaceRaised(for: colorScheme)))
                    }
                    .buttonStyle(.plain)
                    .disabled(setRows.count <= 1)

                    Button {
                        addSet()
                    } label: {
                        Label("Add set", systemImage: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(BFColors.accentInk)
                            .frame(maxWidth: .infinity)
                            .frame(height: BFControlSize.buttonMedium)
                            .background(Capsule().fill(BFColors.accent))
                    }
                    .buttonStyle(.plain)
                    .disabled(setRows.count >= 10)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(BFColors.backgroundElevated(for: colorScheme))
            }
        }
    }

    // MARK: - Weight unit
    // Moved to global Settings.

    // MARK: - Per-set editor

    private var setsEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Sets")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                Text("Tap a value to edit")
                    .font(.caption)
                    .foregroundStyle(BFColors.textTertiary(for: colorScheme))
            }

            VStack(spacing: 0) {
                // Header row
                HStack(spacing: 8) {
                    Text("#")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(BFColors.textTertiary(for: colorScheme))
                        .frame(width: 24, alignment: .leading)
                    Text("KG")
                        .font(.caption.weight(.bold))
                        .frame(maxWidth: .infinity)
                    Text("REPS")
                        .font(.caption.weight(.bold))
                        .frame(maxWidth: .infinity)
                    Color.clear.frame(width: 28)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(BFColors.textTertiary(for: colorScheme))

                ForEach(Array(setRows.enumerated()), id: \.offset) { index, row in
                    setEditorRow(index: index, row: row)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(BFColors.surface(for: colorScheme))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(BFColors.border(for: colorScheme), lineWidth: 1)
            }
        }
    }

    private func setEditorRow(index: Int, row: PlannedSet) -> some View {
        HStack(spacing: 8) {
            Text(String(format: "%02d", index + 1))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                .frame(width: 24, alignment: .leading)

            // KG field
            HStack(spacing: 2) {
                TextField("0", text: loadDraftBinding(for: index, fallback: row.load))
                    .keyboardType(.decimalPad)
                    .font(.system(size: 17, weight: .bold).monospacedDigit())
                    .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .focused($focusedRow, equals: .load(index))
                    .onSubmit { commitLoad(index) }
                    .onChange(of: focusedRow) { _, new in
                        if new != .load(index) { commitLoad(index) }
                    }
                Text("kg")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BFColors.textTertiary(for: colorScheme))
            }
            .padding(.horizontal, 10)
            .frame(height: 38)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(BFColors.surfaceRaised(for: colorScheme))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(
                        focusedRow == .load(index) ? BFColors.accent : BFColors.border(for: colorScheme),
                        lineWidth: focusedRow == .load(index) ? 1.5 : 1
                    )
            }

            // REPS field
            HStack(spacing: 2) {
                TextField("0", text: repsDraftBinding(for: index, fallback: row.reps))
                    .keyboardType(.numberPad)
                    .font(.system(size: 17, weight: .bold).monospacedDigit())
                    .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .focused($focusedRow, equals: .reps(index))
                    .onSubmit { commitReps(index) }
                    .onChange(of: focusedRow) { _, new in
                        if new != .reps(index) { commitReps(index) }
                    }
                Text("reps")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BFColors.textTertiary(for: colorScheme))
            }
            .padding(.horizontal, 10)
            .frame(height: 38)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(BFColors.surfaceRaised(for: colorScheme))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(
                        focusedRow == .reps(index) ? BFColors.accent : BFColors.border(for: colorScheme),
                        lineWidth: focusedRow == .reps(index) ? 1.5 : 1
                    )
            }

            // Remove row button
            Button {
                setRows.remove(at: index)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(BFColors.textTertiary(for: colorScheme))
            }
            .buttonStyle(.plain)
            .frame(width: 28)
            .accessibilityLabel("Remove set \(index + 1)")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(BFColors.separator(for: colorScheme))
                .frame(height: 1)
        }
    }

    // MARK: - Mutations

    private func addSet() {
        let last = setRows.last ?? PlannedSet()
        setRows.append(PlannedSet(load: last.load, reps: last.reps))
    }

    private func removeSet() {
        guard setRows.count > 1 else { return }
        setRows.removeLast()
    }

    private func convertAllLoads(from: WeightUnitSetting, to: WeightUnitSetting) {
        for index in setRows.indices {
            setRows[index].load = to.convert(setRows[index].load, from: from)
        }
    }

    private func loadDraftBinding(for index: Int, fallback: Double) -> Binding<String> {
        Binding(
            get: { rowLoadDraft[index] ?? (fallback > 0 ? formatWeight(fallback) : "") },
            set: { rowLoadDraft[index] = $0 }
        )
    }

    private func repsDraftBinding(for index: Int, fallback: Int) -> Binding<String> {
        Binding(
            get: { rowRepsDraft[index] ?? "\(max(1, fallback))" },
            set: { rowRepsDraft[index] = $0 }
        )
    }

    private func commitLoad(_ index: Int) {
        guard setRows.indices.contains(index) else { return }
        let raw = rowLoadDraft[index] ?? ""
        let cleaned = raw.replacingOccurrences(of: ",", with: ".").filter { $0.isNumber || $0 == "." }
        guard !cleaned.isEmpty, cleaned != ".", let value = Double(cleaned), value > 0 else {
            setRows[index].load = 0
            rowLoadDraft[index] = ""
            return
        }
        setRows[index].load = value
        rowLoadDraft[index] = formatWeight(value)
    }

    private func commitReps(_ index: Int) {
        guard setRows.indices.contains(index) else { return }
        let raw = rowRepsDraft[index] ?? ""
        let digits = raw.filter { $0.isNumber }
        let value = Int(digits.prefix(4)) ?? setRows[index].reps
        let stored = max(1, value)
        setRows[index].reps = stored
        rowRepsDraft[index] = "\(stored)"
    }

    private func formatWeight(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.1f", value)
    }

    // MARK: - Save

    private func saveChanges() {
        // Flush all in-progress drafts so nothing is lost on dismiss.
        for index in 0..<setRows.count { commitLoad(index); commitReps(index) }
        let reps = setRows.first?.reps ?? exercise.repsValue
        let weight = setRows.first?.load ?? exercise.weightValue
        let updated = PlannedExercise(
            id: exercise.id,
            name: exercise.name,
            category: exercise.category,
            sets: setRows.count,
            reps: "\(max(1, reps))",
            targetWeight: weight > 0 ? "\(formatWeight(weight)) \(currentUnit.rawValue)" : nil,
            individualSets: setRows,
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
        theme: .fitbod,
        onDelete: {},
        onReplace: {},
        onSuperset: {},
        onUpdate: { _ in }
    )
}