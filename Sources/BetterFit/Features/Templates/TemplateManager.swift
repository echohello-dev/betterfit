import Foundation

/// Manages reusable workout templates
public class TemplateManager {
    private var templates: [WorkoutTemplate]
    
    public init(templates: [WorkoutTemplate] = []) {
        self.templates = templates
    }
    
    /// Get all templates
    public func getAllTemplates() -> [WorkoutTemplate] {
        return templates
    }
    
    /// Get template by ID
    public func getTemplate(id: UUID) -> WorkoutTemplate? {
        return templates.first { $0.id == id }
    }
    
    /// Add a new template
    public func addTemplate(_ template: WorkoutTemplate) {
        templates.append(template)
    }
    
    /// Update an existing template
    public func updateTemplate(_ template: WorkoutTemplate) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
        }
    }
    
    /// Delete a template
    public func deleteTemplate(id: UUID) {
        templates.removeAll { $0.id == id }
    }
    
    /// Search templates by tag
    public func searchByTag(_ tag: String) -> [WorkoutTemplate] {
        return templates.filter { $0.tags.contains(tag) }
    }
    
    /// Search templates by name
    public func searchByName(_ query: String) -> [WorkoutTemplate] {
        let lowercasedQuery = query.lowercased()
        return templates.filter { $0.name.lowercased().contains(lowercasedQuery) }
    }
    
    /// Get recently used templates
    public func getRecentTemplates(limit: Int = 5) -> [WorkoutTemplate] {
        return templates
            .filter { $0.lastUsedDate != nil }
            .sorted { ($0.lastUsedDate ?? .distantPast) > ($1.lastUsedDate ?? .distantPast) }
            .prefix(limit)
            .map { $0 }
    }
    
    /// Create workout from template
    public func createWorkout(from templateId: UUID) -> Workout? {
        guard let template = getTemplate(id: templateId) else {
            return nil
        }
        
        var updatedTemplate = template
        updatedTemplate.lastUsedDate = Date()
        updateTemplate(updatedTemplate)
        
        return template.createWorkout()
    }
    
    /// Create template from workout
    public func createTemplate(from workout: Workout, name: String, tags: [String] = []) -> WorkoutTemplate {
        let templateExercises = workout.exercises.map { workoutExercise in
            let targetSets = workoutExercise.sets.map { set in
                TargetSet(reps: set.reps, weight: set.weight)
            }
            
            return TemplateExercise(
                exercise: workoutExercise.exercise,
                targetSets: targetSets,
                restTime: nil
            )
        }
        
        return WorkoutTemplate(
            name: name,
            description: nil,
            exercises: templateExercises,
            tags: tags
        )
    }
}
