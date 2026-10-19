import BetterFit
import SwiftUI

// MARK: - Primary Action

struct WatchPrimaryAction: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let title: String
    let symbol: String
    var gestureEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if dynamicTypeSize >= .xxLarge {
                    Text(title)
                } else {
                    Label(title, systemImage: symbol)
                }
            }
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.horizontal, 8)
                .foregroundStyle(WatchTheme.actionInk)
                .background(WatchTheme.accent, in: Capsule())
        }
        .buttonStyle(.plain)
        .watchPrimaryGesture(enabled: gestureEnabled)
    }
}

extension View {
    @ViewBuilder
    func watchPrimaryGesture(enabled: Bool = true) -> some View {
        if #available(watchOS 11.0, *) {
            handGestureShortcut(.primaryAction, isEnabled: enabled)
        } else {
            self
        }
    }
}

// MARK: - Editable Values

enum WorkoutValue: String, Identifiable {
    case reps, weight
    var id: String { rawValue }
    var title: String { self == .reps ? "Reps" : "Weight (lb)" }
    var step: Double { self == .reps ? 1 : 5 }
    var maximum: Double { self == .reps ? 999 : 2_000 }
}

extension WorkoutValue {
    @MainActor
    func binding(to appState: WatchAppState) -> Binding<Double> {
        let setID = appState.session?.currentSet?.id
        return Binding(
            get: {
                guard let set = appState.session?.currentSet else { return 0 }
                return self == .reps ? Double(set.reps) : set.weight ?? 0
            },
            set: { proposed in
                guard proposed.isFinite, let set = appState.session?.currentSet, set.id == setID else { return }
                let bounded = min(max(0, proposed), maximum)
                if self == .reps {
                    appState.session?.adjustReps(by: Int(bounded.rounded()) - set.reps)
                } else if let weight = set.weight {
                    appState.session?.adjustWeight(by: bounded - weight)
                }
            }
        )
    }
}

struct WorkoutValueButton: View {
    @ScaledMetric(relativeTo: .title3) private var valueFontSize = 24
    let metric: WorkoutValue
    @Binding var amount: Double
    let crownFocus: FocusState<WorkoutValue?>.Binding
    let editingEnabled: Bool
    let select: () -> Void
    let useButtons: () -> Void

    private var isSelected: Bool { editingEnabled && crownFocus.wrappedValue == metric }

    private var crownBinding: Binding<Double> {
        Binding(get: { amount }, set: { proposed in
            guard isSelected else { return }
            amount = proposed
        })
    }

    var body: some View {
        Button(action: select) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(amount, format: .number.precision(.fractionLength(0...1)))
                    .font(.system(size: valueFontSize, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(WatchTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(metric == .reps ? "reps" : "lb")
                    .font(.caption2)
                    .foregroundStyle(WatchTheme.textSecondary)
                    .fixedSize()
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(WatchTheme.surfaceRaised, in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? WatchTheme.textPrimary : .clear, lineWidth: 2)
            }
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .focusable(editingEnabled, interactions: .edit)
        .focused(crownFocus, equals: metric)
        .digitalCrownRotation(
            detent: crownBinding, from: 0, through: metric.maximum, by: metric.step,
            sensitivity: .high, isHapticFeedbackEnabled: true
        )
        .contextMenu {
            Button("Edit with Buttons", systemImage: "plusminus", action: useButtons)
        }
        .accessibilityLabel(metric == .weight ? "Weight in pounds" : "Reps")
        .accessibilityValue(amount.formatted())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint("Double tap, then turn the Crown. Button editing is also available in Workout actions.")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: amount += metric.step
            case .decrement: amount -= metric.step
            @unknown default: break
            }
        }
        .accessibilityAction(named: Text("Edit with Buttons"), useButtons)
        .accessibilityIdentifier(metric == .reps ? "rep-count" : "weight-value")
    }
}

struct WorkoutValueEditor: View {
    @EnvironmentObject var appState: WatchAppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @FocusState private var crownFocused: Bool
    @ScaledMetric(relativeTo: .title3) private var valueFontSize = 24
    let value: WorkoutValue

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    if dynamicTypeSize >= .xxLarge {
                        valueDisplay
                        HStack(spacing: 12) {
                            adjustmentButton("Decrease", symbol: "minus", delta: -value.step)
                            adjustmentButton("Increase", symbol: "plus", delta: value.step)
                        }
                    } else {
                        HStack(spacing: 4) {
                            adjustmentButton("Decrease", symbol: "minus", delta: -value.step)
                            valueDisplay
                            adjustmentButton("Increase", symbol: "plus", delta: value.step)
                        }
                    }
                    Label("Turn Crown to adjust", systemImage: "digitalcrown.horizontal.arrow.clockwise")
                        .font(.caption2)
                        .foregroundStyle(WatchTheme.textSecondary)
                }
            }
            .navigationTitle(value.title)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                WatchPrimaryAction(title: "Done", symbol: "checkmark") { dismiss() }
                    .accessibilityIdentifier("finish-editing")
            }
            .onAppear { crownFocused = true }
            .containerBackground(WatchTheme.background, for: .navigation)
        }
        .tint(WatchTheme.surfaceRaised)
    }

    private var valueDisplay: some View {
        Text(currentValue, format: .number.precision(.fractionLength(0...1)))
            .font(.system(size: valueFontSize, weight: .bold).monospacedDigit())
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .frame(maxWidth: .infinity, minHeight: 48)
            .focusable()
            .focused($crownFocused)
            .digitalCrownRotation(
                detent: valueBinding, from: 0, through: value.maximum, by: value.step,
                sensitivity: .low, isHapticFeedbackEnabled: true
            )
            .accessibilityLabel(value.title)
            .accessibilityValue(currentValue.formatted())
            .accessibilityAdjustableAction { direction in
                adjust(by: direction == .increment ? value.step : -value.step)
            }
            .accessibilityIdentifier("edit-value")
    }

    private var currentValue: Double {
        guard let set = appState.session?.currentSet else { return 0 }
        return value == .reps ? Double(set.reps) : set.weight ?? 0
    }

    private var valueBinding: Binding<Double> {
        value.binding(to: appState)
    }

    private func adjust(by delta: Double) {
        valueBinding.wrappedValue = currentValue + delta
    }

    private func adjustmentButton(_ title: String, symbol: String, delta: Double) -> some View {
        Button { adjust(by: delta) } label: {
            Image(systemName: symbol)
                .frame(width: 44, height: 44)
                .background(WatchTheme.surfaceRaised, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title) \(value.title)")
        .accessibilityIdentifier("\(title.lowercased())-\(value.rawValue)")
        .disabled(delta < 0 && currentValue <= 0)
    }
}

// MARK: - Timers

struct WorkoutSetContext: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let session: WorkoutTrackingSession
    let setNumber: Int
    let setCount: Int

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = Int(ceil(session.remainingRest(at: context.date)))
            let layout = dynamicTypeSize >= .xxLarge
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 2))
                : AnyLayout(HStackLayout(spacing: 4))
            layout {
                Text("Set \(setNumber)/\(setCount)")
                    .fixedSize(horizontal: true, vertical: false)
                    .accessibilityLabel("Set \(setNumber) of \(setCount)")
                if dynamicTypeSize < .xxLarge { Spacer(minLength: 4) }
                if session.isPaused {
                    Image(systemName: "pause.fill")
                        .accessibilityLabel("Paused")
                } else if remaining > 0 {
                    let restTime = "\(remaining / 60):\(String(format: "%02d", remaining % 60))"
                    Label(restTime, systemImage: "timer")
                        .fixedSize(horizontal: true, vertical: false)
                        .accessibilityIdentifier("rest-countdown")
                        .accessibilityLabel("Rest: \(remaining) seconds remaining")
                }
            }
            .font(.caption2.monospacedDigit())
            .foregroundStyle(WatchTheme.textSecondary)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("current-set")
        }
    }
}

struct WorkoutElapsedTime: View {
    let session: WorkoutTrackingSession

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let seconds = Int(session.elapsedTime(at: context.date))
            Label(String(format: "%02d:%02d", seconds / 60, seconds % 60), systemImage: "clock")
                .font(.caption.monospacedDigit())
                .foregroundStyle(WatchTheme.textSecondary)
                .accessibilityLabel("Elapsed time")
                .accessibilityValue("\(seconds / 60) minutes, \(seconds % 60) seconds")
                .accessibilityIdentifier("elapsed-time")
        }
    }
}
