import Foundation

/// Manages training plans
public class PlanManager {
    private var plans: [TrainingPlan]
    private var activePlanId: UUID?
    
    public init(plans: [TrainingPlan] = [], activePlanId: UUID? = nil) {
        self.plans = plans
        self.activePlanId = activePlanId
    }
    
    /// Get the currently active plan
    public func getActivePlan() -> TrainingPlan? {
        guard let id = activePlanId else { return nil }
        return plans.first { $0.id == id }
    }
    
    /// Set a plan as active
    public func setActivePlan(_ planId: UUID) {
        guard plans.contains(where: { $0.id == planId }) else { return }
        activePlanId = planId
    }
    
    /// Add a new plan
    public func addPlan(_ plan: TrainingPlan) {
        plans.append(plan)
    }
    
    /// Update an existing plan
    public func updatePlan(_ plan: TrainingPlan) {
        if let index = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[index] = plan
        }
    }
    
    /// Remove a plan
    public func removePlan(_ planId: UUID) {
        plans.removeAll { $0.id == planId }
        if activePlanId == planId {
            activePlanId = nil
        }
    }
    
    /// Get all plans
    public func getAllPlans() -> [TrainingPlan] {
        return plans
    }
}
