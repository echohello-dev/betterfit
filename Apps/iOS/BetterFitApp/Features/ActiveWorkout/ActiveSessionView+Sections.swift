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

    func regionLabel(_ we: WorkoutExercise) -> String {
        we.exercise.muscleGroups.first?.rawValue.capitalized ?? "Lift"
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

    // MARK: - Finish

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
                    : "Log \(BFFormat.trimmed(weight)) × \(reps)",
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
