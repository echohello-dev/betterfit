import BetterFit
import SwiftUI
#if canImport(UIKit)
    import UIKit
#endif

// MARK: - Sections

extension ActiveSessionView {

    // MARK: - Top bar

    var topBar: some View {
        HStack(spacing: 12) {
            Button {
                closeSession()
            } label: {
                Image(systemName: embeddedInTab ? "chevron.down" : "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(embeddedInTab ? "Back to plan" : "Close")

            Text(sessionTitle)
                .font(BFTypography.footnote)
                .monospacedDigit()
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                .frame(maxWidth: .infinity)

            Text(elapsedLabel)
                .font(BFTypography.subheadlineEmphasis)
                .monospacedDigit()
                .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                .padding(.trailing, 6)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }

    var sessionTitle: String {
        let name = workout?.name ?? "Session"
        return "\(name) · \(String(format: "%02d", exerciseIndex + 1)) of \(String(format: "%02d", totalExercises))"
    }

    // MARK: - Exercise header

    func exerciseHeader(_ we: WorkoutExercise) -> some View {
        let total = max(setCount(for: we), 1)
        let currentSet = min(setIndex + 1, total)
        let videoURL = DemoVideoLibrary.videoURL(for: we.exercise.name)
        return VStack(alignment: .leading, spacing: 0) {
            // Demo / form video for the current movement.
            DemoVideoPlayer(
                url: videoURL,
                height: 180,
                fallbackGradient: [
                    BFColors.surfaceRaised(for: colorScheme),
                    BFColors.surface(for: colorScheme),
                ]
            )
            .overlay(alignment: .bottomLeading) {
                if videoURL != nil {
                    Text("FORM")
                        .font(BFTypography.captionEmphasis)
                        .foregroundStyle(BFColors.accentInk)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(BFColors.accent))
                        .padding(10)
                }
            }
            .padding(.bottom, 16)

            BFEyebrow(
                text: "Exercise \(String(format: "%02d", exerciseIndex + 1)) · \(regionLabel(we))",
                color: BFColors.accentText(for: colorScheme)
            )
            Text(we.exercise.name)
                .font(BFTypography.largeTitle)
                .tracking(BFTypography.displayTracking)
                .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                .padding(.top, 8)

            Text("Set \(currentSet) of \(total)")
                .font(BFTypography.eyebrow)
                .textCase(.uppercase)
                .tracking(BFTypography.labelTracking)
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                .padding(.top, 18)

            HStack(spacing: 12) {
                headerField(
                    label: "Weight",
                    unit: "kg",
                    focus: .headerLoad,
                    keyboard: .decimalPad,
                    text: headerLoadDraft(for: we),
                    onCommit: { commitHeaderLoad(we: we) }
                )
                headerField(
                    label: "Reps",
                    unit: nil,
                    focus: .headerReps,
                    keyboard: .numberPad,
                    text: headerRepsDraft(for: we),
                    onCommit: { commitHeaderReps(we: we) }
                )
            }
            .padding(.top, 10)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        commitFocusedField(we: we)
                        focusedField = nil
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .padding(.horizontal, BFSpacing.pageHorizontal)
        .padding(.top, 4)
        .padding(.bottom, 20)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(BFColors.separator(for: colorScheme))
                .frame(height: 1)
        }
    }

    func headerField(
        label: String,
        unit: String?,
        focus: FieldFocus,
        keyboard: UIKeyboardType,
        text: Binding<String>,
        onCommit: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(BFTypography.eyebrow)
                .textCase(.uppercase)
                .tracking(BFTypography.labelTracking)
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))
            HStack(spacing: 4) {
                TextField("0", text: text)
                    .keyboardType(keyboard)
                    .font(BFTypography.stepperValue)
                    .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .focused($focusedField, equals: focus)
                    .onSubmit(onCommit)
                    .onChange(of: focusedField) { _, newValue in
                        if newValue != focus { onCommit() }
                    }
                if let unit {
                    Text(unit)
                        .font(BFTypography.subheadlineEmphasis)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 46)
            .background(
                RoundedRectangle(cornerRadius: BFRadius.medium, style: .continuous)
                    .fill(BFColors.surfaceRaised(for: colorScheme))
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
        .frame(maxWidth: .infinity)
    }

    // MARK: - Rest

    var restBar: some View {
        HStack(spacing: 12) {
            Text("Rest")
                .font(BFTypography.footnoteEmphasis)
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))
            Text(String(format: "%d:%02d", remaining / 60, remaining % 60))
                .font(BFTypography.statMedium)
                .monospacedDigit()
                .foregroundStyle(BFColors.textPrimary(for: colorScheme))
            Spacer()
            Button("+15s") {
                remaining += 15
            }
            .font(BFTypography.footnoteEmphasis)
            .foregroundStyle(BFColors.accentText(for: colorScheme))
            Button("Skip") {
                stopRest()
            }
            .font(BFTypography.footnoteEmphasis)
            .foregroundStyle(BFColors.textSecondary(for: colorScheme))
        }
        .padding(.horizontal, BFSpacing.pageHorizontal)
        .padding(.vertical, 12)
        .background(BFColors.surfaceRaised(for: colorScheme))
    }

    // MARK: - Quick actions

    func quickActions(_ we: WorkoutExercise) -> some View {
        var items: [BFQuickAction] = [
            BFQuickAction(systemImage: "doc.on.doc", label: "Same for all sets") {
                applyCurrentToAll(we)
            },
            BFQuickAction(systemImage: "plus.circle", label: "Add a set") {
                addSet(to: we)
            },
            BFQuickAction(
                systemImage: isSuperset(we.id) ? "link.badge.plus" : "link",
                label: isSuperset(we.id) ? "Unlink superset" : "Superset next"
            ) {
                toggleSuperset(withNextOf: we.id)
            },
            BFQuickAction(systemImage: "arrow.up.arrow.down", label: editMode.isEditing ? "Done ordering" : "Reorder") {
                withAnimation {
                    editMode = editMode.isEditing ? .inactive : .active
                }
            },
            BFQuickAction(systemImage: "timer", label: "Rest \(preferredRest)s") {
                startRest()
            },
        ]
        return BFQuickActions(items: items)
            .padding(.top, 14)
            .padding(.bottom, 4)
    }

    // MARK: - Sets

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

    // MARK: - Session order (all exercises — jump / reorder / superset)

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
                        : "\(done)/\(total) · \(formatNum(pair.load)) kg × \(pair.reps)"
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

    var finishButton: some View {
        Button {
            showFinish = true
        } label: {
            Text("Finish workout")
                .font(BFTypography.subheadlineEmphasis)
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                .frame(maxWidth: .infinity)
                .frame(height: BFControlSize.buttonMedium)
                .overlay {
                    RoundedRectangle(cornerRadius: BFRadius.button, style: .continuous)
                        .stroke(BFColors.borderStrong(for: colorScheme), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, BFSpacing.pageHorizontal)
        .padding(.top, 26)
    }

    // MARK: - Dock

    var dock: some View {
        let complete = current.map { loggedCount(for: $0) >= setCount(for: $0) } ?? true
        return HStack(spacing: 10) {
            BFDockPrimaryButton(
                title: complete
                    ? "Next exercise"
                    : "Log \(formatNum(weight)) × \(reps)",
                systemImage: complete ? "arrow.right" : "checkmark",
                standalone: false
            ) {
                if complete {
                    advanceExercise()
                } else {
                    logCurrentSet()
                }
            }

            BFDockButton(systemImage: "timer", label: "Start rest timer") {
                startRest()
            }
            BFDockButton(systemImage: "plus", label: "Add exercise") {
                showAddExercise = true
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, embeddedInTab ? 78 : 16)
    }

    var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "dumbbell")
                .font(.system(size: 40))
                .foregroundStyle(BFColors.textTertiary(for: colorScheme))
            Text("No exercises planned")
                .font(BFTypography.headline)
            Text("Add a lift to start logging sets.")
                .font(BFTypography.subheadline)
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))
            Button("Add exercise") { showAddExercise = true }
                .buttonStyle(.bfPrimary)
                .padding(.horizontal, 40)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
