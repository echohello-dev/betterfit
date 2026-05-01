import AVKit
import BetterFit
import SwiftUI

// MARK: - Exercise History Entry

struct ExerciseHistoryEntry: Identifiable {
    let id = UUID()
    let date: Date
    let sets: [HistoricalSet]
    let notes: String?

    struct HistoricalSet {
        let reps: Int
        let weight: Double
    }

    var bestSet: HistoricalSet? {
        sets.max { ($0.weight * Double($0.reps)) < ($1.weight * Double($1.reps)) }
    }

    var totalVolume: Double {
        sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
}

// MARK: - Common Weight Suggestion

struct WeightSuggestion: Identifiable {
    let id = UUID()
    let weight: Double
    let label: String
    let isRecent: Bool
}

// MARK: - Workout Exercise Detail View

struct WorkoutExerciseDetailView: View {
    let exercise: WorkoutExerciseState
    let theme: AppTheme
    let onUpdateSet: (Int, Int, Double) -> Void
    let onCompleteSet: (Int) -> Void
    let onAddSet: () -> Void
    let onDeleteSet: ((Int) -> Void)?
    let onCreateSuperset: () -> Void
    let onReplace: (() -> Void)?

    @State private var isVideoExpanded = false
    @State private var selectedSetIndex: Int = 0
    @State private var showNumpadInput = false
    @State private var numpadInputMode: NumpadInputMode = .weight
    @State private var restTimerSeconds: Int = 60
    @State private var isRestTimerRunning = false
    @State private var restTimeRemaining: Int = 60
    @State private var restTimer: Timer?
    @State private var showHistorySheet = false
    @State private var showRestTimerPicker = false

    init(
        exercise: WorkoutExerciseState,
        theme: AppTheme,
        onUpdateSet: @escaping (Int, Int, Double) -> Void,
        onCompleteSet: @escaping (Int) -> Void,
        onAddSet: @escaping () -> Void,
        onDeleteSet: ((Int) -> Void)? = nil,
        onCreateSuperset: @escaping () -> Void,
        onReplace: (() -> Void)? = nil
    ) {
        self.exercise = exercise
        self.theme = theme
        self.onUpdateSet = onUpdateSet
        self.onCompleteSet = onCompleteSet
        self.onAddSet = onAddSet
        self.onDeleteSet = onDeleteSet
        self.onCreateSuperset = onCreateSuperset
        self.onReplace = onReplace
    }

    private var currentSet: WorkoutSetState? {
        guard selectedSetIndex < exercise.sets.count else { return nil }
        return exercise.sets[selectedSetIndex]
    }

    private var nextIncompleteSetIndex: Int? {
        exercise.sets.firstIndex { !$0.isCompleted }
    }

    // Sample history data (would come from BetterFit in production)
    private var exerciseHistory: [ExerciseHistoryEntry] {
        [
            ExerciseHistoryEntry(
                date: Calendar.current.date(byAdding: .day, value: -3, to: .now)!,
                sets: [
                    .init(reps: 10, weight: 135),
                    .init(reps: 8, weight: 155),
                    .init(reps: 6, weight: 175),
                ],
                notes: nil
            ),
            ExerciseHistoryEntry(
                date: Calendar.current.date(byAdding: .day, value: -7, to: .now)!,
                sets: [
                    .init(reps: 10, weight: 135),
                    .init(reps: 10, weight: 145),
                    .init(reps: 8, weight: 155),
                ],
                notes: "Felt strong today"
            ),
            ExerciseHistoryEntry(
                date: Calendar.current.date(byAdding: .day, value: -14, to: .now)!,
                sets: [
                    .init(reps: 12, weight: 125),
                    .init(reps: 10, weight: 135),
                    .init(reps: 8, weight: 145),
                ],
                notes: nil
            ),
        ]
    }

    // Common weights used for this exercise
    private var weightSuggestions: [WeightSuggestion] {
        var suggestions: [WeightSuggestion] = []

        // Get weights from history
        // Add recent weights first
        if let lastEntry = exerciseHistory.first {
            for setData in lastEntry.sets.prefix(3) {
                suggestions.append(
                    WeightSuggestion(
                        weight: setData.weight,
                        label: "\(Int(setData.weight))",
                        isRecent: true
                    ))
            }
        }

        // Add common increment weights
        let baseWeight = currentSet?.weight ?? 135
        let increments: [Double] = [-10, -5, 5, 10]
        for inc in increments {
            let newWeight = baseWeight + inc
            if newWeight > 0 && !suggestions.contains(where: { $0.weight == newWeight }) {
                suggestions.append(
                    WeightSuggestion(
                        weight: newWeight,
                        label: inc > 0 ? "+\(Int(inc))" : "\(Int(inc))",
                        isRecent: false
                    ))
            }
        }

        return suggestions
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Video preview with gradient overlay
                videoPreviewSection

                // Quick action bar
                quickActionBar

                // Rest timer (if running)
                if isRestTimerRunning {
                    restTimerView
                }

                // History sneak peek
                historyPeekSection

                Divider().opacity(0.3).padding(.horizontal, 16)

                // Sets tracking with swipe to delete
                setsSection
            }
        }
        .sheet(isPresented: $showNumpadInput) {
            NumpadInputView(
                mode: numpadInputMode,
                reps: currentSet?.reps ?? 10,
                weight: currentSet?.weight ?? 0,
                theme: theme
            ) { reps, weight in
                onUpdateSet(selectedSetIndex, reps, weight)
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showHistorySheet) {
            exerciseHistorySheet
        }
        .sheet(isPresented: $showRestTimerPicker) {
            restTimerPickerSheet
        }
        .onAppear {
            if let nextIndex = nextIncompleteSetIndex {
                selectedSetIndex = nextIndex
            }
        }
        .onDisappear {
            restTimer?.invalidate()
        }
    }

    // MARK: - Video Preview Section

    private var videoPreviewSection: some View {
        ZStack(alignment: .bottom) {
            // Video/placeholder background
            if let videoURL = exercise.exercise.videoURL {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .frame(height: isVideoExpanded ? 300 : 180)
                    .clipped()
            } else {
                // Gradient placeholder with exercise icon
                ZStack {
                    LinearGradient(
                        colors: categoryGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    VStack(spacing: 12) {
                        Image(systemName: categorySystemImage)
                            .font(.system(size: isVideoExpanded ? 64 : 44, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))

                        if isVideoExpanded {
                            Text(exercise.exercise.name)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white)

                            Text(exercise.exercise.muscleGroups.joined(separator: " • "))
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                }
                .frame(height: isVideoExpanded ? 300 : 180)
            }

            // Gradient overlay for sneak peek
            if !isVideoExpanded {
                LinearGradient(
                    colors: [
                        .clear, .clear, Color(uiColor: .systemBackground).opacity(0.8),
                        Color(uiColor: .systemBackground),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 180)

                // Exercise name and expand button
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.exercise.name)
                            .font(.title3.weight(.bold))

                        HStack(spacing: 8) {
                            Text(exercise.exercise.muscleGroups.joined(separator: ", "))
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if exercise.isSuperset {
                                Label("Superset", systemImage: "link")
                                    .font(.caption2.weight(.semibold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(theme.accent.opacity(0.2)))
                                    .foregroundStyle(theme.accent)
                            }
                        }
                    }

                    Spacer()

                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            isVideoExpanded = true
                        }
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(Circle().fill(theme.accent))
                    }
                }
                .padding(16)
            }

            // Collapse button when expanded
            if isVideoExpanded {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                isVideoExpanded = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(12)
                        }
                    }
                    Spacer()
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: isVideoExpanded ? 0 : 16, style: .continuous))
        .padding(.horizontal, isVideoExpanded ? 0 : 16)
        .padding(.top, isVideoExpanded ? 0 : 8)
    }

    private var categoryGradientColors: [Color] {
        switch exercise.exercise.category {
        case .push: return [.blue, .cyan]
        case .pull: return [.purple, .pink]
        case .legs: return [.orange, .yellow]
        case .core: return [.yellow, .orange]
        case .cardio: return [.red, .orange]
        case .compound: return [.green, .teal]
        case .all: return [.gray, .secondary]
        }
    }

    private var categorySystemImage: String {
        switch exercise.exercise.category {
        case .push: return "arrow.up"
        case .pull: return "arrow.down"
        case .legs: return "figure.walk"
        case .core: return "circle.circle"
        case .cardio: return "heart"
        case .compound: return "dumbbell.fill"
        case .all: return "figure.mixed.cardio"
        }
    }

    // MARK: - Quick Action Bar

    private var quickActionBar: some View {
        HStack(spacing: 12) {
            // Rest Timer button
            Button {
                showRestTimerPicker = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "timer")
                    Text(formatRestTime(restTimerSeconds))
                }
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Capsule().fill(.regularMaterial))
                .overlay(Capsule().stroke(theme.cardStroke, lineWidth: 1))
            }

            // History button
            Button {
                showHistorySheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("History")
                }
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Capsule().fill(.regularMaterial))
                .overlay(Capsule().stroke(theme.cardStroke, lineWidth: 1))
            }

            Spacer()

            // Replace button
            if let replaceAction = onReplace {
                Button(action: replaceAction) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Replace")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(.orange.opacity(0.15)))
                }
            }

            // Superset button
            Button(action: onCreateSuperset) {
                Image(systemName: "link.badge.plus")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(theme.accent)
                    .padding(8)
                    .background(Circle().fill(theme.accent.opacity(0.15)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Rest Timer View

    private var restTimerView: some View {
        HStack(spacing: 16) {
            // Timer circle
            ZStack {
                Circle()
                    .stroke(theme.cardStroke, lineWidth: 4)
                    .frame(width: 50, height: 50)

                Circle()
                    .trim(from: 0, to: CGFloat(restTimeRemaining) / CGFloat(restTimerSeconds))
                    .stroke(theme.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: restTimeRemaining)

                Text("\(restTimeRemaining)")
                    .font(.subheadline.weight(.bold).monospacedDigit())
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Rest Timer")
                    .font(.subheadline.weight(.semibold))
                Text("Take a breather")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Skip button
            Button {
                stopRestTimer()
            } label: {
                Text("Skip")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.accent)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(theme.accent.opacity(0.15)))
            }
        }
        .padding(16)
        .background(theme.accent.opacity(0.1))
    }

    // MARK: - History Peek Section

    private var historyPeekSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Last Workout")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                if let lastEntry = exerciseHistory.first {
                    Text(lastEntry.date.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let lastEntry = exerciseHistory.first {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(lastEntry.sets.enumerated()), id: \.offset) {
                            index, setData in
                            VStack(spacing: 4) {
                                Text("\(setData.reps)")
                                    .font(.subheadline.weight(.bold))
                                Text("\(Int(setData.weight)) lbs")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(
                                    .regularMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(
                                    theme.cardStroke, lineWidth: 1))
                        }

                        // View more button
                        Button {
                            showHistorySheet = true
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "ellipsis")
                                    .font(.subheadline)
                                Text("More")
                                    .font(.caption)
                            }
                            .foregroundStyle(theme.accent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(
                                    theme.accent.opacity(0.1)))
                        }
                    }
                }
            } else {
                Text("No history yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
    }

    // MARK: - Sets Section

    private var setsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with progress
            HStack {
                Text("Sets")
                    .font(.headline)

                Spacer(minLength: 0)

                // Progress indicator
                let completed = exercise.sets.filter(\.isCompleted).count
                HStack(spacing: 4) {
                    ForEach(0..<exercise.sets.count, id: \.self) { index in
                        Circle()
                            .fill(index < completed ? theme.accent : theme.cardStroke)
                            .frame(width: 8, height: 8)
                    }
                }
            }

            // Weight suggestions
            if !weightSuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick weights")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(weightSuggestions) { suggestion in
                                WeightSuggestionButton(
                                    suggestion: suggestion,
                                    theme: theme,
                                    onSelect: { weight in
                                        onUpdateSet(
                                            selectedSetIndex, currentSet?.reps ?? 10, weight)
                                    }
                                )
                            }
                        }
                    }
                }
            }

            // Sets list with swipe to delete
            VStack(spacing: 10) {
                ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, setItem in
                    SetRowView(
                        workoutSet: setItem,
                        index: index,
                        isSelected: index == selectedSetIndex,
                        theme: theme,
                        onTapReps: {
                            selectedSetIndex = index
                            numpadInputMode = .reps
                            showNumpadInput = true
                        },
                        onTapWeight: {
                            selectedSetIndex = index
                            numpadInputMode = .weight
                            showNumpadInput = true
                        },
                        onComplete: {
                            onCompleteSet(index)
                            // Start rest timer after completing a set
                            if !exercise.sets.allSatisfy({ $0.isCompleted || $0.id == setItem.id })
                            {
                                startRestTimer()
                            }
                            // Move to next set
                            if index + 1 < exercise.sets.count {
                                selectedSetIndex = index + 1
                            }
                        },
                        onSelect: {
                            selectedSetIndex = index
                        },
                        onDelete: onDeleteSet != nil
                            ? {
                                withAnimation {
                                    onDeleteSet?(index)
                                }
                            } : nil
                    )
                }
            }

            // Add set button
            Button {
                onAddSet()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Set")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(theme.accent, style: StrokeStyle(lineWidth: 2, dash: [6]))
                }
            }
        }
        .padding(16)
    }

    // MARK: - History Sheet

    private var exerciseHistorySheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Summary stats
                    HStack(spacing: 16) {
                        statCard(
                            title: "Best Set",
                            value: "\(Int(exerciseHistory.first?.bestSet?.weight ?? 0)) lbs",
                            icon: "trophy.fill", color: .yellow)
                        statCard(
                            title: "Sessions", value: "\(exerciseHistory.count)", icon: "calendar",
                            color: theme.accent)
                    }

                    Divider()

                    // History entries
                    ForEach(exerciseHistory) { entry in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline.weight(.semibold))
                                Spacer()
                                Text("\(Int(entry.totalVolume)) lbs volume")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            HStack(spacing: 8) {
                                ForEach(Array(entry.sets.enumerated()), id: \.offset) {
                                    idx, setData in
                                    VStack(spacing: 2) {
                                        Text("Set \(idx + 1)")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                        Text("\(setData.reps) × \(Int(setData.weight))")
                                            .font(.caption.weight(.semibold))
                                    }
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8).fill(.regularMaterial))
                                }
                            }

                            if let notes = entry.notes {
                                HStack(spacing: 6) {
                                    Image(systemName: "note.text")
                                        .font(.caption)
                                    Text(notes)
                                        .font(.caption)
                                }
                                .foregroundStyle(.secondary)
                            }
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(.regularMaterial))
                    }
                }
                .padding(16)
            }
            .navigationTitle("\(exercise.exercise.name) History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showHistorySheet = false }
                }
            }
        }
        .presentationDetents([.large])
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title3.weight(.bold))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(.regularMaterial))
    }

    // MARK: - Rest Timer Picker Sheet

    private var restTimerPickerSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Rest Timer")
                    .font(.headline)

                // Preset buttons
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 12
                ) {
                    ForEach([30, 45, 60, 90, 120, 180], id: \.self) { seconds in
                        Button {
                            restTimerSeconds = seconds
                        } label: {
                            Text(formatRestTime(seconds))
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12).fill(
                                        restTimerSeconds == seconds ? theme.accent : Color.clear
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12).stroke(
                                        restTimerSeconds == seconds
                                            ? theme.accent : theme.cardStroke,
                                        lineWidth: restTimerSeconds == seconds ? 2 : 1
                                    )
                                )
                                .foregroundStyle(restTimerSeconds == seconds ? .white : .primary)
                        }
                    }
                }

                // Custom stepper
                HStack {
                    Text("Custom")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Stepper(value: $restTimerSeconds, in: 10...300, step: 10) {
                        Text(formatRestTime(restTimerSeconds))
                            .font(.subheadline.weight(.semibold))
                            .monospacedDigit()
                    }
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 12).fill(.regularMaterial))

                Spacer()
            }
            .padding(16)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showRestTimerPicker = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Timer Helpers

    private func formatRestTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        if mins > 0 && secs > 0 {
            return "\(mins)m \(secs)s"
        } else if mins > 0 {
            return "\(mins) min"
        } else {
            return "\(secs)s"
        }
    }

    private func startRestTimer() {
        restTimeRemaining = restTimerSeconds
        isRestTimerRunning = true
        restTimer?.invalidate()
        restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if restTimeRemaining > 0 {
                restTimeRemaining -= 1
            } else {
                stopRestTimer()
            }
        }
    }

    private func stopRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
        isRestTimerRunning = false
    }
}

// MARK: - Weight Suggestion Button

private struct WeightSuggestionButton: View {
    let suggestion: WeightSuggestion
    let theme: AppTheme
    let onSelect: (Double) -> Void

    var body: some View {
        Button {
            onSelect(suggestion.weight)
        } label: {
            Text(displayText)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(backgroundView)
                .overlay(overlayView)
                .foregroundStyle(foregroundColor)
        }
    }

    private var displayText: String {
        if suggestion.isRecent {
            return "\(Int(suggestion.weight)) lbs"
        }
        return suggestion.label
    }

    private var backgroundView: some View {
        Capsule().fill(suggestion.isRecent ? theme.accent.opacity(0.15) : Color(.systemFill))
    }

    private var overlayView: some View {
        Capsule().stroke(suggestion.isRecent ? theme.accent : theme.cardStroke, lineWidth: 1)
    }

    private var foregroundColor: Color {
        suggestion.isRecent ? theme.accent : .primary
    }
}

// MARK: - Set Row View

private struct SetRowView: View {
    let workoutSet: WorkoutSetState
    let index: Int
    let isSelected: Bool
    let theme: AppTheme
    let onTapReps: () -> Void
    let onTapWeight: () -> Void
    let onComplete: () -> Void
    let onSelect: () -> Void
    let onDelete: (() -> Void)?

    @State private var offset: CGFloat = 0
    @State private var isShowingDelete = false

    private var isCompleted: Bool { workoutSet.isCompleted }

    private var numberColor: Color {
        isSelected ? theme.accent : Color.secondary
    }

    private var inputStrokeWidth: CGFloat {
        isSelected ? 2 : 1
    }

    private var rowStrokeWidth: CGFloat {
        isSelected ? 2 : 1
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete button background
            if onDelete != nil {
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            onDelete?()
                        }
                    } label: {
                        Image(systemName: "trash.fill")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 60, height: 60)
                    }
                    .background(Color.red)
                }
            }

            // Main row content
            HStack(spacing: 14) {
                setNumberCircle
                repsInput
                weightInput
                Spacer(minLength: 0)
                completeButton
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(
                    rowStrokeColor, lineWidth: rowStrokeWidth)
            )
            .offset(x: offset)
            .gesture(
                onDelete != nil
                    ? DragGesture()
                        .onChanged { value in
                            if value.translation.width < 0 {
                                offset = max(value.translation.width, -80)
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.3)) {
                                if value.translation.width < -40 {
                                    offset = -70
                                    isShowingDelete = true
                                } else {
                                    offset = 0
                                    isShowingDelete = false
                                }
                            }
                        }
                    : nil
            )
            .contentShape(Rectangle())
            .onTapGesture {
                if isShowingDelete {
                    withAnimation(.spring(response: 0.3)) {
                        offset = 0
                        isShowingDelete = false
                    }
                } else if !isCompleted {
                    onSelect()
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    @ViewBuilder
    private var setNumberCircle: some View {
        ZStack {
            if isCompleted {
                Circle()
                    .fill(theme.accent)
                    .frame(width: 32, height: 32)
            } else if isSelected {
                Circle()
                    .fill(theme.accent.opacity(0.2))
                    .frame(width: 32, height: 32)
            } else {
                Circle()
                    .fill(theme.cardBackground)
                    .frame(width: 32, height: 32)
            }

            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
            } else {
                Text("\(index + 1)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(numberColor)
            }
        }
    }

    private var inputStrokeColor: Color {
        isSelected ? theme.accent : theme.cardStroke
    }

    private var rowStrokeColor: Color {
        if isCompleted {
            return Color.green.opacity(0.5)
        } else if isSelected {
            return theme.accent
        } else {
            return theme.cardStroke
        }
    }

    @ViewBuilder
    private var repsInput: some View {
        Button(action: onTapReps) {
            VStack(spacing: 2) {
                Text("\(workoutSet.reps)")
                    .font(.title3.weight(.bold))
                    .monospacedDigit()

                Text("reps")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 60)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(
                    inputStrokeColor, lineWidth: inputStrokeWidth))
        }
        .buttonStyle(.plain)
        .disabled(isCompleted)
    }

    @ViewBuilder
    private var weightInput: some View {
        Button(action: onTapWeight) {
            VStack(spacing: 2) {
                Text(workoutSet.weight > 0 ? "\(Int(workoutSet.weight))" : "—")
                    .font(.title3.weight(.bold))
                    .monospacedDigit()

                Text("lbs")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 70)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(
                    inputStrokeColor, lineWidth: inputStrokeWidth))
        }
        .buttonStyle(.plain)
        .disabled(isCompleted)
    }

    @ViewBuilder
    private var completeButton: some View {
        if !isCompleted {
            Button(action: onComplete) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(theme.accent)
            }
        } else {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(.green)
        }
    }
}

#Preview {
    WorkoutExerciseDetailView(
        exercise: WorkoutExerciseState(
            id: UUID(),
            exercise: ExerciseDefinition(
                id: UUID(),
                name: "Bench Press",
                category: .push,
                muscleGroups: ["Chest", "Triceps", "Shoulders"],
                videoURL: nil,
                description:
                    "Lie on a flat bench, grip the bar slightly wider than shoulder-width.",
                aliases: ["Flat Bench Press", "Barbell Bench"],
                relatedExercises: ["Incline Press", "Dumbbell Press", "Push-ups"]
            ),
            sets: [
                WorkoutSetState(id: UUID(), reps: 10, weight: 135, isCompleted: true),
                WorkoutSetState(id: UUID(), reps: 8, weight: 155),
                WorkoutSetState(id: UUID(), reps: 6, weight: 175),
            ]
        ),
        theme: .forest,
        onUpdateSet: { _, _, _ in },
        onCompleteSet: { _ in },
        onAddSet: {},
        onDeleteSet: { _ in },
        onCreateSuperset: {},
        onReplace: {}
    )
}
