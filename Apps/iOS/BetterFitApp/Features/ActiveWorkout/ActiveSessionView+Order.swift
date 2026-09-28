import BetterFit
import SwiftUI

// MARK: - Session order (all exercises — jump / reorder / superset)

extension ActiveSessionView {

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

    // MARK: - Session order section

    var sessionOrderSection: some View {
        let list = exercises
        let incomplete = list.filter { loggedCount(for: $0) < setCount(for: $0) }.count
        return VStack(alignment: .leading, spacing: 0) {
            BFSectionRule(
                label: "Session",
                trailing: editMode.isEditing ? "Drag to reorder" : "\(incomplete) left · tap any"
            )

            if editMode.isEditing {
                ForEach(Array(list.enumerated()), id: \.element.id) { index, we in
                    sessionOrderRow(we: we, index: index, showsDrag: true)
                }
            } else {
                ForEach(Array(list.enumerated()), id: \.element.id) { index, we in
                    sessionOrderRow(we: we, index: index, showsDrag: false)
                }
            }

            BFAddRow { showAddExercise = true }
        }
        .padding(.horizontal, BFSpacing.pageHorizontal)
    }

    func sessionOrderRow(we: WorkoutExercise, index: Int, showsDrag: Bool) -> some View {
        let done = loggedCount(for: we)
        let total = setCount(for: we)
        let isCurrent = index == exerciseIndex
        let pair = setValues(for: we, index: min(done, max(total - 1, 0)))
        let ssLabel = supersetLabel(for: we.id)

        let row = HStack(spacing: 12) {
            // Superset rail
            ZStack {
                if isSuperset(we.id) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(BFColors.accent)
                        .frame(width: 3)
                }
                Text(String(format: "%02d", index + 1))
                    .font(BFTypography.gutter)
                    .foregroundStyle(
                        isCurrent
                            ? BFColors.accentText(for: colorScheme)
                            : BFColors.textTertiary(for: colorScheme)
                    )
                    .frame(width: 28, alignment: .leading)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(we.exercise.name)
                        .font(BFTypography.bodyEmphasis)
                        .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                    if let ssLabel {
                        Text(ssLabel)
                            .font(BFTypography.captionEmphasis)
                            .foregroundStyle(BFColors.accentInk)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(BFColors.accent))
                    }
                }
                Text(
                    done >= total
                        ? "Done · \(total) sets"
                        : "\(done)/\(total) · \(BFFormat.trimmed(pair.load)) kg × \(pair.reps)"
                )
                .font(BFTypography.footnote)
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))
            }

            Spacer(minLength: 0)

            sessionOrderTrailing(index: index, isCurrent: isCurrent, showsDrag: showsDrag, done: done, total: total)
        }
        .padding(.vertical, 12)
        .opacity(done >= total && !isCurrent ? 0.55 : 1)
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
        .contentShape(Rectangle())

        return Group {
            if showsDrag {
                row
            } else {
                Button { jumpTo(index) } label: { row }
                    .buttonStyle(.plain)
            }
        }
        .contextMenu {
            sessionOrderContextMenu(we: we, index: index, isCurrent: isCurrent)
        }
    }

    // MARK: - Session order row parts

    @ViewBuilder
    private func sessionOrderTrailing(index: Int, isCurrent: Bool, showsDrag: Bool, done: Int, total: Int) -> some View {
        if showsDrag {
            HStack(spacing: 4) {
                Button {
                    moveExercise(from: index, to: index - 1)
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 13, weight: .bold))
                        .frame(width: 32, height: 32)
                }
                .disabled(index == 0)
                Button {
                    moveExercise(from: index, to: index + 1)
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .bold))
                        .frame(width: 32, height: 32)
                }
                .disabled(index >= exercises.count - 1)
            }
            .foregroundStyle(BFColors.textPrimary(for: colorScheme))
            .buttonStyle(.plain)
        } else if done >= total {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(BFColors.accentText(for: colorScheme))
        } else if isCurrent {
            Text("Now")
                .font(BFTypography.captionEmphasis)
                .foregroundStyle(BFColors.accentText(for: colorScheme))
        } else {
            Image(systemName: "play.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(BFColors.accentText(for: colorScheme))
        }
    }

    @ViewBuilder
    private func sessionOrderContextMenu(we: WorkoutExercise, index: Int, isCurrent: Bool) -> some View {
        if index > 0 {
            Button {
                moveExercise(from: index, to: index - 1)
            } label: {
                Label("Move up", systemImage: "arrow.up")
            }
        }
        if index < exercises.count - 1 {
            Button {
                moveExercise(from: index, to: index + 1)
            } label: {
                Label("Move down", systemImage: "arrow.down")
            }
            Button {
                linkSuperset(index, with: index + 1)
            } label: {
                Label("Superset with next", systemImage: "link")
            }
        }
        if isSuperset(we.id) {
            Button(role: .destructive) {
                unlinkSuperset(we.id)
            } label: {
                Label("Break superset", systemImage: "link.badge.plus")
            }
        }
        if !isCurrent {
            Button {
                jumpTo(index)
            } label: {
                Label("Train now", systemImage: "play.fill")
            }
        }
    }
}
