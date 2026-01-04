import Foundation

// MARK: - Exercise Template Category

/// Categories for exercise templates, used to organize and filter exercises
public enum ExerciseTemplateCategory: String, CaseIterable, Sendable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case arms = "Arms"
    case legs = "Legs"
    case core = "Core"
}

// MARK: - Exercise Template

/// A template for an exercise, used for discovery and adding to workouts
public struct ExerciseTemplate: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let subtitle: String
    public let category: ExerciseTemplateCategory

    public init(
        id: UUID = UUID(),
        name: String,
        subtitle: String,
        category: ExerciseTemplateCategory
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.category = category
    }
}

// MARK: - Default Exercise Templates

extension ExerciseTemplate {
    /// All built-in exercise templates
    public static let allTemplates: [ExerciseTemplate] = [
        // Chest
        ExerciseTemplate(name: "Bench Press", subtitle: "Chest • Triceps", category: .chest),
        ExerciseTemplate(
            name: "Incline Dumbbell Press", subtitle: "Chest • Shoulders", category: .chest),
        ExerciseTemplate(
            name: "Dumbbell Incline Bench Press", subtitle: "Chest • Shoulders", category: .chest),
        ExerciseTemplate(name: "Dumbbell Incline Fly", subtitle: "Chest", category: .chest),

        // Back
        ExerciseTemplate(name: "Deadlift", subtitle: "Back • Legs", category: .back),
        ExerciseTemplate(name: "Pull Up", subtitle: "Back • Arms", category: .back),
        ExerciseTemplate(name: "Lat Pulldown", subtitle: "Back", category: .back),
        ExerciseTemplate(name: "Barbell Row", subtitle: "Back", category: .back),
        ExerciseTemplate(name: "Romanian Deadlift", subtitle: "Hamstrings • Back", category: .back),

        // Shoulders
        ExerciseTemplate(
            name: "Overhead Press", subtitle: "Shoulders • Triceps", category: .shoulders),
        ExerciseTemplate(
            name: "Seated Dumbbell Front Press", subtitle: "Shoulders", category: .shoulders),

        // Arms
        ExerciseTemplate(name: "Bicep Curl", subtitle: "Arms", category: .arms),
        ExerciseTemplate(name: "Seated Dumbbell Curl", subtitle: "Biceps", category: .arms),
        ExerciseTemplate(name: "Dumbbell Tricep Extension", subtitle: "Triceps", category: .arms),
        ExerciseTemplate(name: "Cable Tricep Pushdown", subtitle: "Triceps", category: .arms),

        // Legs
        ExerciseTemplate(name: "Squat", subtitle: "Legs • Core", category: .legs),
        ExerciseTemplate(name: "Leg Press", subtitle: "Quads • Glutes", category: .legs),
        ExerciseTemplate(name: "Leg Extension", subtitle: "Quads", category: .legs),
        ExerciseTemplate(name: "Leg Curl", subtitle: "Hamstrings", category: .legs),
        ExerciseTemplate(name: "Calf Raise", subtitle: "Calves", category: .legs),

        // Core
        ExerciseTemplate(name: "Cable Crunch", subtitle: "Abs • Core", category: .core),
        ExerciseTemplate(name: "Cable Wood Chop", subtitle: "Obliques • Core", category: .core),
        ExerciseTemplate(name: "Plank", subtitle: "Core", category: .core),
        ExerciseTemplate(name: "Hanging Leg Raise", subtitle: "Abs • Core", category: .core),
    ]

    /// Get templates filtered by category
    public static func templates(for category: ExerciseTemplateCategory) -> [ExerciseTemplate] {
        allTemplates.filter { $0.category == category }
    }

    /// Search templates by name or subtitle
    public static func search(_ query: String) -> [ExerciseTemplate] {
        guard !query.isEmpty else { return allTemplates }
        let lowercased = query.lowercased()
        return allTemplates.filter {
            $0.name.lowercased().contains(lowercased)
                || $0.subtitle.lowercased().contains(lowercased)
        }
    }
}
