import BetterFit
import SwiftUI

struct ActiveWorkoutView: View {
    @EnvironmentObject var appState: WatchAppState
    let workout: Workout

    @State private var currentWorkout: Workout
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isPaused: Bool = false

    init(workout: Workout) {
        self.workout = workout
        _currentWorkout = State(initialValue: workout)
    }

    var currentExercise: WorkoutExercise? {
        guard appState.currentExerciseIndex < currentWorkout.exercises.count else {
            return nil
        }
        return currentWorkout.exercises[appState.currentExerciseIndex]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 4) {
                    Text(currentWorkout.name)
                        .font(.headline)
                        .foregroundStyle(WatchTheme.textPrimary)

                    HStack(spacing: 8) {
                        Text(timeString(from: elapsedTime))
                            .font(.title2)
                            .foregroundStyle(isPaused ? WatchTheme.accent : WatchTheme.success)
                            .monospacedDigit()

                        Button {
                            isPaused.toggle()
                        } label: {
                            Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                                .font(.title2)
                                .foregroundStyle(isPaused ? WatchTheme.success : WatchTheme.accent)
                        }
                        .buttonStyle(.plain)
                    }

                    if isPaused {
                        Text("Paused")
                            .font(.caption2)
                            .foregroundStyle(WatchTheme.accent)
                    }
                }
                .padding(.top)

                if let exercise = currentExercise {
                    ExerciseTracker(
                        exercise: exercise,
                        onUpdate: { updatedExercise in
                            currentWorkout.exercises[appState.currentExerciseIndex] =
                                updatedExercise
                            appState.updateActiveWorkout(currentWorkout)
                        }
                    )
                } else {
                    // Workout complete
                    CompleteWorkoutView()
                }

                // Navigation buttons
                HStack(spacing: 12) {
                    if appState.currentExerciseIndex > 0 {
                        Button {
                            appState.currentExerciseIndex -= 1
                        } label: {
                            Label("Previous", systemImage: "chevron.left")
                                .font(.headline)
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }

                    if appState.currentExerciseIndex < currentWorkout.exercises.count - 1 {
                        Button {
                            appState.currentExerciseIndex += 1
                        } label: {
                            Label("Next", systemImage: "chevron.right")
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(WatchTheme.accent)
                        .frame(maxWidth: .infinity)
                    } else {
                        Button {
                            appState.completeWorkout()
                        } label: {
                            Label("Finish", systemImage: "checkmark")
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(WatchTheme.success)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)

                // End workout button
                Button(role: .destructive) {
                    appState.completeWorkout()
                } label: {
                    Text("End Workout")
                        .font(.caption)
                        .foregroundStyle(WatchTheme.danger)
                }
                .padding(.bottom)
            }
        }
        .background(WatchTheme.background.ignoresSafeArea())
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            if !isPaused {
                elapsedTime += 0.01
            }
        }
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        let milliseconds = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

struct ExerciseTracker: View {
    let exercise: WorkoutExercise
    let onUpdate: (WorkoutExercise) -> Void

    @State private var currentExercise: WorkoutExercise
    @State private var currentSetIndex: Int = 0

    init(exercise: WorkoutExercise, onUpdate: @escaping (WorkoutExercise) -> Void) {
        self.exercise = exercise
        self.onUpdate = onUpdate
        _currentExercise = State(initialValue: exercise)
    }

    var currentSet: ExerciseSet? {
        guard currentSetIndex < currentExercise.sets.count else { return nil }
        return currentExercise.sets[currentSetIndex]
    }

    var body: some View {
        VStack(spacing: 12) {
            // Exercise name
            Text(currentExercise.exercise.name)
                .font(.title3)
                .bold()
                .foregroundStyle(WatchTheme.textPrimary)

            // Set progress
            Text("Set \(currentSetIndex + 1) of \(currentExercise.sets.count)")
                .font(.caption)
                .foregroundStyle(WatchTheme.textSecondary)

            if let set = currentSet {
                VStack(spacing: 16) {
                    // Reps display
                    VStack(spacing: 4) {
                        Text("Reps")
                            .font(.caption)
                            .foregroundStyle(WatchTheme.textSecondary)

                        HStack(spacing: 16) {
                            Button {
                                updateReps(by: -1)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(WatchTheme.accent)

                            Text("\(set.reps)")
                                .font(.system(size: 48, weight: .bold))
                                .monospacedDigit()
                                .foregroundStyle(WatchTheme.textPrimary)
                                .frame(minWidth: 60)

                            Button {
                                updateReps(by: 1)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(WatchTheme.accent)
                        }
                    }

                    // Weight display (if applicable)
                    if let weight = set.weight {
                        VStack(spacing: 4) {
                            Text("Weight (lbs)")
                                .font(.caption)
                                .foregroundStyle(WatchTheme.textSecondary)

                            HStack(spacing: 16) {
                                Button {
                                    updateWeight(by: -5)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(WatchTheme.accent)

                                Text("\(Int(weight))")
                                    .font(.system(size: 32, weight: .bold))
                                    .monospacedDigit()
                                    .foregroundStyle(WatchTheme.textPrimary)
                                    .frame(minWidth: 60)

                                Button {
                                    updateWeight(by: 5)
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(WatchTheme.accent)
                            }
                        }
                    }

                    // Complete set button
                    Button {
                        completeCurrentSet()
                    } label: {
                        Label(
                            set.isCompleted ? "Completed" : "Complete Set",
                            systemImage: set.isCompleted
                                ? "checkmark.circle.fill" : "checkmark.circle"
                        )
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(set.isCompleted ? WatchTheme.success : WatchTheme.accent)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(WatchTheme.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(WatchTheme.border, lineWidth: 1)
                        )
                )
            }
        }
        .padding(.horizontal)
    }

    private func updateReps(by delta: Int) {
        guard currentSetIndex < currentExercise.sets.count else { return }
        let newReps = max(0, currentExercise.sets[currentSetIndex].reps + delta)
        currentExercise.sets[currentSetIndex].reps = newReps
        onUpdate(currentExercise)
    }

    private func updateWeight(by delta: Double) {
        guard currentSetIndex < currentExercise.sets.count else { return }
        if let currentWeight = currentExercise.sets[currentSetIndex].weight {
            let newWeight = max(0, currentWeight + delta)
            currentExercise.sets[currentSetIndex].weight = newWeight
            onUpdate(currentExercise)
        }
    }

    private func completeCurrentSet() {
        guard currentSetIndex < currentExercise.sets.count else { return }

        currentExercise.sets[currentSetIndex].isCompleted = true
        currentExercise.sets[currentSetIndex].timestamp = Date()
        onUpdate(currentExercise)

        // Auto-advance to next set
        if currentSetIndex < currentExercise.sets.count - 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                currentSetIndex += 1
            }
        }
    }
}

struct CompleteWorkoutView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(WatchTheme.success)

            Text("All Done!")
                .font(.title2)
                .bold()
                .foregroundStyle(WatchTheme.textPrimary)

            Text("Great work on completing your workout!")
                .font(.caption)
                .foregroundStyle(WatchTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
