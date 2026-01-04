import BetterFit
import Foundation
import SwiftUI

// MARK: - Workout Plan Day

/// Represents a single day in the workout plan
struct WorkoutPlanDay: Identifiable, Equatable {
    let id: UUID
    let date: Date
    var workoutType: WorkoutType?
    var exercises: [PlannedExercise]
    var isRest: Bool
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        date: Date,
        workoutType: WorkoutType? = nil,
        exercises: [PlannedExercise] = [],
        isRest: Bool = false,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.date = date
        self.workoutType = workoutType
        self.exercises = exercises
        self.isRest = isRest
        self.isCompleted = isCompleted
    }

    // Custom Equatable to compare by id only (avoid PlannedExercise array issues)
    static func == (lhs: WorkoutPlanDay, rhs: WorkoutPlanDay) -> Bool {
        lhs.id == rhs.id
    }

    var dayOfWeek: String {
        date.formatted(.dateTime.weekday(.abbreviated))
    }

    var fullDayName: String {
        date.formatted(.dateTime.weekday(.wide))
    }

    var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    /// Convert the plan day to a Workout for starting/executing
    func toWorkout() -> Workout {
        let workoutName = workoutType?.rawValue ?? "Today's Workout"
        let workoutExercises = exercises.map { $0.toWorkoutExercise() }
        return Workout(
            name: workoutName,
            exercises: workoutExercises,
            date: date
        )
    }
}

// MARK: - Workout Type

enum WorkoutType: String, CaseIterable, Equatable {
    case push = "Push"
    case pull = "Pull"
    case legs = "Legs"
    case upper = "Upper"
    case lower = "Lower"
    case fullBody = "Full Body"
    case cardio = "Cardio"
    case rest = "Rest"

    var icon: String {
        switch self {
        case .push: return "arrow.up.circle.fill"
        case .pull: return "arrow.down.circle.fill"
        case .legs: return "figure.walk"
        case .upper: return "figure.arms.open"
        case .lower: return "figure.run"
        case .fullBody: return "figure.strengthtraining.traditional"
        case .cardio: return "heart.fill"
        case .rest: return "moon.fill"
        }
    }

    var primaryCategory: ExerciseCategory {
        switch self {
        case .push: return .push
        case .pull: return .pull
        case .legs: return .legs
        case .upper: return .push
        case .lower: return .legs
        case .fullBody: return .compound
        case .cardio: return .cardio
        case .rest: return .all
        }
    }
}

// MARK: - Workout Plan Manager

/// Manages the workout plan for multiple weeks
@Observable
final class WorkoutPlanManager {
    private(set) var planDays: [Date: WorkoutPlanDay] = [:]
    private let calendar = Calendar.current

    // Push/Pull/Legs split pattern
    private let splitPattern: [WorkoutType?] = [.push, nil, .pull, .legs, nil, .upper, nil]

    init() {
        generateInitialPlan()
    }

    // MARK: - Plan Generation

    /// Generate a 4-week workout plan starting from today
    func generateInitialPlan() {
        let today = calendar.startOfDay(for: Date.now)

        // Generate 4 weeks (28 days) of workouts
        for dayOffset in 0..<28 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else {
                continue
            }

            let weekdayIndex = (calendar.component(.weekday, from: date) + 5) % 7  // Mon=0, Sun=6
            let workoutType = splitPattern[weekdayIndex]
            let isRest = workoutType == nil

            let exercises = isRest ? [] : generateExercises(for: workoutType!)

            planDays[date] = WorkoutPlanDay(
                date: date,
                workoutType: workoutType,
                exercises: exercises,
                isRest: isRest
            )
        }
    }

    /// Get the plan day for a specific date
    func getPlanDay(for date: Date) -> WorkoutPlanDay? {
        let startOfDay = calendar.startOfDay(for: date)
        return planDays[startOfDay]
    }

    /// Get today's plan day
    func getTodayPlan() -> WorkoutPlanDay? {
        getPlanDay(for: Date.now)
    }

    /// Get the current week's plan days
    func getCurrentWeekDays() -> [WorkoutPlanDay] {
        let today = calendar.startOfDay(for: Date.now)
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7

        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else {
            return []
        }

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: monday) else {
                return nil
            }
            return planDays[date] ?? WorkoutPlanDay(date: date, isRest: true)
        }
    }

    /// Get plan days for a date range
    func getPlanDays(from startDate: Date, to endDate: Date) -> [WorkoutPlanDay] {
        var days: [WorkoutPlanDay] = []
        var currentDate = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)

        while currentDate <= end {
            if let planDay = planDays[currentDate] {
                days.append(planDay)
            } else {
                days.append(WorkoutPlanDay(date: currentDate, isRest: true))
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = next
        }

        return days
    }

    // MARK: - Exercise Management

    /// Update exercises for a specific date
    func updateExercises(for date: Date, exercises: [PlannedExercise]) {
        let startOfDay = calendar.startOfDay(for: date)
        if var planDay = planDays[startOfDay] {
            planDay.exercises = exercises
            planDays[startOfDay] = planDay
        }
    }

    /// Add exercise to a date
    func addExercise(_ exercise: PlannedExercise, to date: Date) {
        let startOfDay = calendar.startOfDay(for: date)
        if var planDay = planDays[startOfDay] {
            planDay.exercises.append(exercise)
            planDays[startOfDay] = planDay
        } else {
            // Create a new plan day if one doesn't exist
            let newDay = WorkoutPlanDay(
                date: startOfDay,
                workoutType: .fullBody,
                exercises: [exercise],
                isRest: false
            )
            planDays[startOfDay] = newDay
        }
    }

    /// Add exercise to today's plan
    func addExerciseToToday(_ exercise: PlannedExercise) {
        addExercise(exercise, to: Date.now)
    }

    /// Remove exercise from a date
    func removeExercise(at index: Int, from date: Date) {
        let startOfDay = calendar.startOfDay(for: date)
        if var planDay = planDays[startOfDay], planDay.exercises.indices.contains(index) {
            planDay.exercises.remove(at: index)
            planDays[startOfDay] = planDay
        }
    }

    /// Replace exercise at index
    func replaceExercise(at index: Int, with exercise: PlannedExercise, on date: Date) {
        let startOfDay = calendar.startOfDay(for: date)
        if var planDay = planDays[startOfDay], planDay.exercises.indices.contains(index) {
            planDay.exercises[index] = exercise
            planDays[startOfDay] = planDay
        }
    }

    /// Move exercise from one index to another
    func moveExercise(from source: IndexSet, to destination: Int, on date: Date) {
        let startOfDay = calendar.startOfDay(for: date)
        if var planDay = planDays[startOfDay] {
            planDay.exercises.move(fromOffsets: source, toOffset: destination)
            planDays[startOfDay] = planDay
        }
    }

    /// Mark a day as completed
    func markDayCompleted(_ date: Date) {
        let startOfDay = calendar.startOfDay(for: date)
        if var planDay = planDays[startOfDay] {
            planDay.isCompleted = true
            planDays[startOfDay] = planDay
        }
    }

    /// Set the selected workout for today (when user swipes to a different suggested workout)
    func setSelectedWorkoutForToday(_ workout: Workout) {
        let today = calendar.startOfDay(for: Date.now)

        // Convert workout exercises to PlannedExercise
        let plannedExercises = workout.exercises.map { workoutExercise -> PlannedExercise in
            let category = categorize(exercise: workoutExercise.exercise)
            let muscleGroups = workoutExercise.exercise.muscleGroups.map { prettify($0) }
            let weight = workoutExercise.sets.first?.weight.map { "\(Int($0)) lbs" }
            let reps = workoutExercise.sets.first.map { "\($0.reps)" } ?? "10"

            return PlannedExercise(
                name: workoutExercise.exercise.name,
                category: category,
                sets: workoutExercise.sets.count,
                reps: reps,
                targetWeight: weight,
                muscleGroups: muscleGroups
            )
        }

        // Determine workout type from name
        let workoutType = inferWorkoutType(from: workout.name)

        // Update or create today's plan
        planDays[today] = WorkoutPlanDay(
            id: planDays[today]?.id ?? UUID(),
            date: today,
            workoutType: workoutType,
            exercises: plannedExercises,
            isRest: false,
            isCompleted: planDays[today]?.isCompleted ?? false
        )
    }

    private func categorize(exercise: Exercise) -> ExerciseCategory {
        let name = exercise.name.lowercased()
        if name.contains("press") || name.contains("push") {
            return .push
        } else if name.contains("row") || name.contains("pull") || name.contains("curl") {
            return .pull
        } else if name.contains("squat") || name.contains("leg") || name.contains("lunge") {
            return .legs
        } else if name.contains("plank") || name.contains("crunch") || name.contains("ab") {
            return .core
        } else if name.contains("run") || name.contains("bike") || name.contains("cardio") {
            return .cardio
        }
        return .compound
    }

    private func prettify(_ group: MuscleGroup) -> String {
        group.rawValue.prefix(1).uppercased() + group.rawValue.dropFirst()
    }

    private func inferWorkoutType(from name: String) -> WorkoutType? {
        let lowercased = name.lowercased()
        if lowercased.contains("push") { return .push }
        if lowercased.contains("pull") { return .pull }
        if lowercased.contains("leg") { return .legs }
        if lowercased.contains("upper") { return .upper }
        if lowercased.contains("lower") { return .lower }
        if lowercased.contains("full") { return .fullBody }
        if lowercased.contains("cardio") || lowercased.contains("run") { return .cardio }
        return nil
    }

    // MARK: - Exercise Generation

    private func generateExercises(for workoutType: WorkoutType) -> [PlannedExercise] {
        switch workoutType {
        case .push:
            return [
                PlannedExercise(
                    name: "Bench Press", category: .push, sets: 4, reps: "8-10",
                    targetWeight: "135 lbs", muscleGroups: ["Chest", "Triceps"]),
                PlannedExercise(
                    name: "Overhead Press", category: .push, sets: 3, reps: "8-10",
                    targetWeight: "95 lbs", muscleGroups: ["Shoulders", "Triceps"]),
                PlannedExercise(
                    name: "Incline Dumbbell Press", category: .push, sets: 3, reps: "10-12",
                    targetWeight: "50 lbs", muscleGroups: ["Upper Chest"]),
                PlannedExercise(
                    name: "Tricep Pushdowns", category: .push, sets: 3, reps: "12-15",
                    targetWeight: "40 lbs", muscleGroups: ["Triceps"]),
            ]
        case .pull:
            return [
                PlannedExercise(
                    name: "Deadlift", category: .pull, sets: 4, reps: "5", targetWeight: "225 lbs",
                    muscleGroups: ["Back", "Hamstrings", "Glutes"]),
                PlannedExercise(
                    name: "Pull-ups", category: .pull, sets: 4, reps: "8-10",
                    muscleGroups: ["Lats", "Biceps"]),
                PlannedExercise(
                    name: "Barbell Row", category: .pull, sets: 3, reps: "8",
                    targetWeight: "135 lbs", muscleGroups: ["Back", "Biceps"]),
                PlannedExercise(
                    name: "Face Pulls", category: .pull, sets: 3, reps: "15",
                    targetWeight: "30 lbs", muscleGroups: ["Rear Delts", "Traps"]),
            ]
        case .legs:
            return [
                PlannedExercise(
                    name: "Squat", category: .legs, sets: 4, reps: "6-8", targetWeight: "185 lbs",
                    muscleGroups: ["Quads", "Glutes"]),
                PlannedExercise(
                    name: "Romanian Deadlift", category: .legs, sets: 3, reps: "10-12",
                    targetWeight: "135 lbs", muscleGroups: ["Hamstrings", "Glutes"]),
                PlannedExercise(
                    name: "Leg Press", category: .legs, sets: 3, reps: "12-15",
                    targetWeight: "270 lbs", muscleGroups: ["Quads"]),
                PlannedExercise(
                    name: "Calf Raises", category: .legs, sets: 4, reps: "15-20",
                    targetWeight: "100 lbs", muscleGroups: ["Calves"]),
            ]
        case .upper:
            return [
                PlannedExercise(
                    name: "Bench Press", category: .push, sets: 3, reps: "8-10",
                    targetWeight: "135 lbs", muscleGroups: ["Chest"]),
                PlannedExercise(
                    name: "Barbell Row", category: .pull, sets: 3, reps: "8-10",
                    targetWeight: "135 lbs", muscleGroups: ["Back"]),
                PlannedExercise(
                    name: "Shoulder Press", category: .push, sets: 3, reps: "10-12",
                    targetWeight: "65 lbs", muscleGroups: ["Shoulders"]),
                PlannedExercise(
                    name: "Lat Pulldown", category: .pull, sets: 3, reps: "10-12",
                    targetWeight: "100 lbs", muscleGroups: ["Lats"]),
            ]
        case .lower:
            return [
                PlannedExercise(
                    name: "Squat", category: .legs, sets: 4, reps: "6-8", targetWeight: "185 lbs",
                    muscleGroups: ["Quads", "Glutes"]),
                PlannedExercise(
                    name: "Leg Curl", category: .legs, sets: 3, reps: "12-15",
                    targetWeight: "80 lbs", muscleGroups: ["Hamstrings"]),
                PlannedExercise(
                    name: "Hip Thrust", category: .legs, sets: 3, reps: "10-12",
                    targetWeight: "135 lbs", muscleGroups: ["Glutes"]),
                PlannedExercise(
                    name: "Calf Raises", category: .legs, sets: 3, reps: "15-20",
                    targetWeight: "100 lbs", muscleGroups: ["Calves"]),
            ]
        case .fullBody:
            return [
                PlannedExercise(
                    name: "Squat", category: .legs, sets: 3, reps: "8-10", targetWeight: "155 lbs",
                    muscleGroups: ["Quads", "Glutes"]),
                PlannedExercise(
                    name: "Bench Press", category: .push, sets: 3, reps: "8-10",
                    targetWeight: "135 lbs", muscleGroups: ["Chest"]),
                PlannedExercise(
                    name: "Barbell Row", category: .pull, sets: 3, reps: "8-10",
                    targetWeight: "115 lbs", muscleGroups: ["Back"]),
                PlannedExercise(
                    name: "Overhead Press", category: .push, sets: 3, reps: "8-10",
                    targetWeight: "85 lbs", muscleGroups: ["Shoulders"]),
            ]
        case .cardio:
            return [
                PlannedExercise(
                    name: "Treadmill Run", category: .cardio, sets: 1, reps: "30 min",
                    muscleGroups: ["Cardio"])
            ]
        case .rest:
            return []
        }
    }
}

// MARK: - Exercise Category Extension

extension ExerciseCategory {
    var categoryColor: Color {
        switch self {
        case .push: return .blue
        case .pull: return .purple
        case .legs: return .orange
        case .core: return .yellow
        case .cardio: return .red
        case .compound: return .green
        case .all: return .gray
        }
    }
}
