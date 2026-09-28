import SwiftUI
import BetterFit
import Auth

// MARK: - Plan sections (Workout tab)

extension WorkoutHomeView {
    // MARK: - Top bar (title only)

    var topBar: some View {
        HStack(spacing: 10) {
            Text("Plan")
                .font(BFTypography.screenTitle)
                .tracking(BFTypography.displayTracking)
                .foregroundStyle(BFColors.textPrimary(for: colorScheme))
            Spacer(minLength: 0)
            BFIconButton(systemImage: "magnifyingglass", accessibilityLabel: "Search", action: onSearch)
            Button(action: onProfile) {
                Text(initials)
                    .font(BFTypography.captionEmphasis)
                    .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(BFColors.surfaceRaised(for: colorScheme)))
                    .overlay {
                        Circle().stroke(BFColors.border(for: colorScheme), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Profile")
        }
        .padding(.horizontal, BFSpacing.pageHorizontal)
        .padding(.bottom, 14)
        .padding(.top, 8)
        .background(BFColors.background(for: colorScheme))
    }

    // MARK: - Header

    var header: some View {
        BFHeaderBlock(
            eyebrow: eyebrow,
            title: sessionName,
            specs: [
                BFSpecItem(value: "\(exercises.count)", label: "Exercises"),
                BFSpecItem(value: "\(plannedMinutes)'", label: "Planned"),
                BFSpecItem(value: "\(max(muscleCount, 1))", label: "Muscles"),
            ],
            yellow: theme.prefersYellowHeaders
        )
    }

    // MARK: - Quick actions

    var quickActions: some View {
        BFQuickActions(items: [
            BFQuickAction(systemImage: "arrow.left.arrow.right", label: "Swap session") {
                cycleSession()
            },
            BFQuickAction(systemImage: "pencil", label: "Edit") {},
            BFQuickAction(systemImage: "arrow.counterclockwise", label: "Repeat last") {
                repeatLast()
            },
            BFQuickAction(systemImage: "clock", label: "Trim to 30 min") {
                trimToThirty()
            },
            BFQuickAction(systemImage: "dumbbell.fill", label: "Gym") {
                showEquipment = true
            },
        ])
    }

    // MARK: - The work

    var workList: some View {
        VStack(alignment: .leading, spacing: 0) {
            BFSectionRule(label: "The work", trailing: "Swipe left to pair · right to replace/remove")

            ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                exerciseRow(exercise, index: index)
                    .contextMenu {
                        Button {
                            moveToTop(exercise)
                        } label: {
                            Label("To top", systemImage: "arrow.up.to.line")
                        }
                        Button {
                            selectedExercise = exercise
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        if BFSupersetStore.shared.isLinked(exercise.id) {
                            Button(role: .destructive) {
                                BFSupersetStore.shared.unlink(exercise.id)
                            } label: {
                                Label("Break superset", systemImage: "link.badge.plus")
                            }
                        } else if index + 1 < exercises.count {
                            Button {
                                BFSupersetStore.shared.link(exercise.id, exercises[index + 1].id)
                            } label: {
                                Label("Superset with next", systemImage: "link")
                            }
                        }
                        Button(role: .destructive) {
                            remove(exercise)
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
            }

            BFAddRow { showAddExercise = true }
        }
    }

    func exerciseRow(_ exercise: PlannedExercise, index: Int) -> some View {
        let focus = index == 0
        return planRowContent(exercise, index: index, focus: focus)
            .padding(.vertical, 12)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(BFColors.separator(for: colorScheme))
                    .frame(height: 1)
            }
            .overlay(alignment: .leading) {
                if focus {
                    Rectangle()
                        .fill(BFColors.accent)
                        .frame(width: 3)
                        .offset(x: -BFSpacing.pageHorizontal)
                }
            }
            .swipeActions(edge: .leading) {
                Button {
                    if index + 1 < exercises.count {
                        pairSuperset(currentIndex: index, withIndex: index + 1)
                    }
                } label: {
                    Label("Superset", systemImage: "link")
                }
                .tint(BFColors.accent)
            }
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    removePlanExercise(exercise)
                } label: {
                    Label("Remove", systemImage: "trash")
                }
                Button {
                    selectedExercise = exercise
                } label: {
                    Label("Replace", systemImage: "arrow.triangle.2.circlepath")
                }
                .tint(BFColors.accent)
            }
    }

    private func planRowContent(_ exercise: PlannedExercise, index: Int, focus: Bool) -> some View {
        let superset = BFSupersetStore.shared.partner(of: exercise.id)
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                Text(String(format: "%02d", index + 1))
                    .font(BFTypography.gutter)
                    .foregroundStyle(
                        focus
                            ? BFColors.accentText(for: colorScheme)
                            : BFColors.textTertiary(for: colorScheme)
                    )
                    .frame(width: 28, alignment: .leading)

                exerciseThumbTile(exercise)

                Button {
                    selectedExercise = exercise
                } label: {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(exercise.name)
                            .font(BFTypography.bodyEmphasis)
                            .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                            .multilineTextAlignment(.leading)
                        Text(meta(for: exercise, index: index, focus: focus))
                            .font(BFTypography.footnote)
                            .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)

                Text("\(exercise.sets) sets")
                    .font(BFTypography.caption)
                    .foregroundStyle(BFColors.textTertiary(for: colorScheme))

                if superset != nil {
                    // Neutral chip — yellow stays reserved for the single
                    // primary action/hero (design.md "Yellow versus amber").
                    Text("SS")
                        .font(BFTypography.captionEmphasis)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(BFColors.surfaceRaised(for: colorScheme)))
                        .overlay {
                            Capsule().stroke(BFColors.border(for: colorScheme), lineWidth: 1)
                        }
                }
            }

            planEditFields(for: exercise)
        }
    }

    /// Small leading thumbnail tile — an SF Symbol glyph in a rounded tinted tile
    /// (no photo assets exist; reuses the `thumbIcon` mapping convention).
    private func exerciseThumbTile(_ exercise: PlannedExercise) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(theme.accentSurface(0.12, for: colorScheme))
            Image(systemName: thumbIcon(for: exercise))
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(BFColors.accentText(for: colorScheme))
        }
        .frame(width: 40, height: 40)
        .accessibilityHidden(true)
    }

    private func planEditFields(for exercise: PlannedExercise) -> some View {
        HStack(spacing: 10) {
            planInput(
                label: "kg",
                text: weightDraft(for: exercise),
                focus: .weight(exercise.id),
                keyboard: .decimalPad,
                onCommit: { commitWeight(exercise.id) }
            )
            Text("\u{00D7}")
                .font(BFTypography.subheadlineEmphasis)
                .foregroundStyle(BFColors.textTertiary(for: colorScheme))
            planInput(
                label: "reps",
                text: repsDraft(for: exercise),
                focus: .reps(exercise.id),
                keyboard: .numberPad,
                onCommit: { commitReps(exercise.id) }
            )
            Spacer(minLength: 0)
        }
        // Align under the text column: 28pt gutter + 40pt thumbnail + 2×12pt gaps.
        .padding(.leading, 92)
    }

    // MARK: - Start something else

    var otherSessions: some View {
        let list = source == "suggested" ? suggested : frequent
        return VStack(alignment: .leading, spacing: 0) {
            BFSectionRule(
                label: "Start something else",
                trailing: source == "suggested" ? "Based on recovery" : "Most used"
            )
            BFSourceSwitch(
                selection: $source,
                options: [("suggested", "Suggested"), ("frequent", "Frequent")]
            )

            VStack(spacing: 0) {
                ForEach(Array(list.enumerated()), id: \.element.name) { _, item in
                    let preview = previewForName(item.name)
                    BFLedgerRow(
                        systemImage: "dumbbell.fill",
                        title: item.name,
                        meta: item.meta,
                        dim: item.dim
                    ) {
                        Button {
                            adoptSession(named: item.name)
                        } label: {
                            Image(systemName: "play.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(BFColors.accentText(for: colorScheme))
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(BFColors.surfaceRaised(for: colorScheme)))
                                .overlay {
                                    Circle().stroke(BFColors.border(for: colorScheme), lineWidth: 1)
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Start \(item.name)")
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let preview { workoutPreview = preview }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            // Superset this one with the next in the active plan
                            guard let preview else { return }
                            if let exerciseIndex = exercises.firstIndex(where: { $0.name == preview.name }),
                               exerciseIndex + 1 < exercises.count
                            {
                                BFSupersetStore.shared.link(exercises[exerciseIndex].id, exercises[exerciseIndex + 1].id)
                            }
                        } label: {
                            Label("Superset next", systemImage: "link")
                        }
                        .tint(BFColors.accent)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            // Adopt this preview as the current plan
                            if let preview { replaceWorkoutPreview(preview) }
                        } label: {
                            Label("Replace", systemImage: "arrow.triangle.2.circlepath")
                        }
                        .tint(BFColors.accent)
                        Button(role: .destructive) {
                            // Drop the suggested workout and fall back to the default demo.
                            exercises = Self.demoPullDay
                            sessionName = "Pull Day"
                            workoutType = .pull
                            persistExercises()
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Equipment sheet

    var equipmentSheet: some View {
        NavigationStack {
            List {
                ForEach(Equipment.allCases, id: \.self) { eq in
                    Button {
                        if availableEquipment.contains(eq) {
                            availableEquipment.remove(eq)
                        } else {
                            availableEquipment.insert(eq)
                        }
                    } label: {
                        HStack {
                            Text(eq.rawValue.capitalized)
                                .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                            Spacer()
                            if availableEquipment.contains(eq) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(BFColors.accentText(for: colorScheme))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Equipment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showEquipment = false }
                }
            }
        }
    }
}
