import SwiftUI

// MARK: - Input Mode

enum NumpadInputMode: String, CaseIterable {
    case reps
    case weight

    var unit: String {
        switch self {
        case .reps: return "reps"
        case .weight: return "lbs"
        }
    }

    var quickIncrements: [Double] {
        switch self {
        case .reps: return [1, 5]
        case .weight: return [5, 10]
        }
    }
}

// MARK: - Numpad Input View

struct NumpadInputView: View {
    let initialMode: NumpadInputMode
    let repsValue: Double
    let weightValue: Double
    let theme: AppTheme
    let onSave: (Int, Double) -> Void

    @State private var currentMode: NumpadInputMode
    @State private var currentReps: Double
    @State private var currentWeight: Double
    @State private var inputString: String = ""
    @Environment(\.dismiss) private var dismiss

    init(
        mode: NumpadInputMode = .weight,
        reps: Int,
        weight: Double,
        theme: AppTheme,
        onSave: @escaping (Int, Double) -> Void
    ) {
        self.initialMode = mode
        self.repsValue = Double(reps)
        self.weightValue = weight
        self.theme = theme
        self.onSave = onSave
        _currentMode = State(initialValue: mode)
        _currentReps = State(initialValue: Double(reps))
        _currentWeight = State(initialValue: weight)
        let initialValue = mode == .reps ? Double(reps) : weight
        _inputString = State(initialValue: initialValue > 0 ? formatValue(initialValue) : "")
    }

    private var currentValue: Double {
        get { currentMode == .reps ? currentReps : currentWeight }
        set {
            if currentMode == .reps {
                currentReps = newValue
            } else {
                currentWeight = newValue
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with cancel/done
            headerBar
                .padding(.horizontal, 16)
                .padding(.top, 12)

            // Mode toggle + value display
            valueSection
                .padding(.top, 16)
                .padding(.bottom, 12)

            // Quick increment buttons
            quickIncrementBar
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

            // Numpad
            numpadGrid
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
        .background(Color(uiColor: .systemBackground))
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .foregroundStyle(.secondary)

            Spacer()

            Button("Done") {
                onSave(Int(currentReps), currentWeight)
                dismiss()
            }
            .fontWeight(.semibold)
            .foregroundStyle(theme.accent)
        }
    }

    // MARK: - Value Section

    private var valueSection: some View {
        HStack(spacing: 24) {
            // Reps button
            valueButton(mode: .reps, value: currentReps)

            // Weight button
            valueButton(mode: .weight, value: currentWeight)
        }
        .padding(.horizontal, 20)
    }

    private func valueButton(mode: NumpadInputMode, value: Double) -> some View {
        let isSelected = currentMode == mode

        return Button {
            switchMode(to: mode)
        } label: {
            VStack(spacing: 4) {
                Text(formatValue(value))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .monospacedDigit()

                Text(mode.unit)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? theme.accent.opacity(0.15) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? theme.accent : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? .primary : .secondary)
    }

    // MARK: - Quick Increment Bar

    private var quickIncrementBar: some View {
        HStack(spacing: 12) {
            ForEach(currentMode.quickIncrements, id: \.self) { increment in
                HStack(spacing: 8) {
                    // Plus button
                    Button {
                        adjustValue(by: increment)
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(theme.accent.opacity(0.15)))
                            .foregroundStyle(theme.accent)
                    }

                    // Minus button
                    Button {
                        adjustValue(by: -increment)
                    } label: {
                        Image(systemName: "minus")
                            .font(.body.weight(.semibold))
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color(uiColor: .secondarySystemFill)))
                            .foregroundStyle(.primary)
                    }

                    // Label
                    Text("±\(formatIncrement(increment))")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 36)
                }
            }
        }
    }

    // MARK: - Numpad Grid

    private var numpadGrid: some View {
        let buttons: [[NumpadButton]] = [
            [.digit(1), .digit(2), .digit(3)],
            [.digit(4), .digit(5), .digit(6)],
            [.digit(7), .digit(8), .digit(9)],
            [.clear, .digit(0), .delete],
        ]

        return VStack(spacing: 10) {
            ForEach(0..<buttons.count, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(buttons[row], id: \.self) { button in
                        numpadButton(button)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func numpadButton(_ button: NumpadButton) -> some View {
        Button {
            handleNumpadPress(button)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemFill))
                    .frame(height: 56)

                switch button {
                case .digit(let num):
                    Text("\(num)")
                        .font(.title2.weight(.semibold))

                case .decimal:
                    Text(".")
                        .font(.title2.weight(.semibold))

                case .delete:
                    Image(systemName: "delete.left")
                        .font(.title3.weight(.medium))

                case .clear:
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.orange)
                }
            }
            .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func switchMode(to mode: NumpadInputMode) {
        // Save current input to the right variable
        let parsedValue = Double(inputString) ?? 0
        if currentMode == .reps {
            currentReps = parsedValue
        } else {
            currentWeight = parsedValue
        }

        // Switch mode
        currentMode = mode

        // Load the new mode's value
        let newValue = mode == .reps ? currentReps : currentWeight
        inputString = formatValue(newValue)
    }

    private func handleNumpadPress(_ button: NumpadButton) {
        switch button {
        case .digit(let num):
            if inputString == "0" {
                inputString = "\(num)"
            } else {
                inputString += "\(num)"
            }

        case .decimal:
            if !inputString.contains(".") {
                inputString += inputString.isEmpty ? "0." : "."
            }

        case .delete:
            if !inputString.isEmpty {
                inputString.removeLast()
            }

        case .clear:
            inputString = ""
        }

        syncValueFromInput()
    }

    private func adjustValue(by amount: Double) {
        let newValue = max(0, currentValue + amount)
        if currentMode == .reps {
            currentReps = newValue
        } else {
            currentWeight = newValue
        }
        inputString = formatValue(newValue)
    }

    private func syncValueFromInput() {
        let parsedValue = Double(inputString) ?? 0
        if currentMode == .reps {
            currentReps = parsedValue
        } else {
            currentWeight = parsedValue
        }
    }

    // MARK: - Helpers

    private func formatIncrement(_ value: Double) -> String {
        if value == floor(value) {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }
}

private func formatValue(_ value: Double) -> String {
    if value == floor(value) {
        return "\(Int(value))"
    }
    return String(format: "%.1f", value)
}

// MARK: - Numpad Button

private enum NumpadButton: Hashable {
    case digit(Int)
    case decimal
    case delete
    case clear
}

#Preview {
    NumpadInputView(
        mode: .weight,
        reps: 5,
        weight: 225,
        theme: .forest
    ) { reps, weight in
        print("Reps: \(reps), Weight: \(weight)")
    }
}
