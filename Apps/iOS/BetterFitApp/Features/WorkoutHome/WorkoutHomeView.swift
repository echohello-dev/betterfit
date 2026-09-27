import Auth
import BetterFit
import SwiftUI
#if canImport(UIKit)
    import UIKit
#endif

// MARK: - Plan (Workout tab) — Ledger layout

struct WorkoutHomeView: View {
    @Environment(\.colorScheme) var colorScheme

    let betterFit: BetterFit
    let theme: AppTheme
    let healthKitManager: HealthKitManager?
    let planManager: WorkoutPlanManager?
    let isGuest: Bool
    let user: Auth.User?
    let demoModeOverride: Bool?
    var onSearch: () -> Void = {}
    var onProfile: () -> Void = {}

    @State var exercises: [PlannedExercise] = []
    @State var sessionName = "Pull Day"
    @State var workoutType: WorkoutType? = .pull
    @State var source = "suggested"
    @State var showAddExercise = false
    @State var showEquipment = false
    @State var availableEquipment: Set<Equipment> = Set(Equipment.allCases)
    @State var selectedExercise: PlannedExercise?
    @State var workoutPreview: WorkoutPreview?
    /// When set, the add-exercise sheet swaps this exercise in place (Replace flow).
    @State var replaceTargetId: UUID?
    /// Collapses the large title into a compact search nav when the user scrolls.
    @State var isScrolled = false
    /// Draft text for plan-mode weight/reps editing.
    @State var draftWeight: [UUID: String] = [:]
    @State var draftReps: [UUID: String] = [:]
    @FocusState var focusedPlanField: PlanField?

    enum PlanField: Hashable {
        case weight(UUID)
        case reps(UUID)
    }

    #if DEBUG
        @AppStorage("betterfit.workoutHome.demoMode") var demoModeEnabled = true
    #else
        var demoModeEnabled: Bool { false }
    #endif

    init(
        betterFit: BetterFit,
        theme: AppTheme,
        healthKitManager: HealthKitManager? = nil,
        planManager: WorkoutPlanManager? = nil,
        isGuest: Bool = false,
        user: Auth.User? = nil,
        demoMode: Bool? = nil,
        onSearch: @escaping () -> Void = {},
        onProfile: @escaping () -> Void = {}
    ) {
        self.betterFit = betterFit
        self.theme = theme
        self.healthKitManager = healthKitManager
        self.planManager = planManager
        self.isGuest = isGuest
        self.user = user
        self.demoModeOverride = demoMode
        self.onSearch = onSearch
        self.onProfile = onProfile
    }

    // MARK: - Derived

    var todayPlan: WorkoutPlanDay? {
        planManager?.getTodayPlan()
    }

    var plannedMinutes: Int {
        max(20, exercises.count * 6)
    }

    var muscleCount: Int {
        Set(exercises.flatMap(\.muscleGroups)).count
    }

    var dateLabel: String {
        Date.now.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
    }

    var initials: String {
        let name = user?.email?.prefix(2) ?? (isGuest ? "GU" : "BF")
        return String(name).uppercased()
    }

    var eyebrow: String {
        let type = workoutType?.rawValue ?? "Train"
        return "Today · \(type)"
    }

    var suggested: [(name: String, meta: String, dim: Bool)] {
        [
            (sessionName, "Recommended · \(plannedMinutes) min · based on recovery", false),
            ("Legs A", "52 min · quads and glutes", false),
            ("Push B", "44 min · chest and shoulders", true),
        ]
    }

    var frequent: [(name: String, meta: String, dim: Bool)] {
        [
            ("Pull B", "Done 14 times · last Tuesday", false),
            ("Push A", "Done 12 times · last Monday", false),
            ("Legs A", "Done 9 times · last Thursday", false),
            ("Conditioning", "Done 6 times · last Saturday", false),
        ]
    }

    var otherSessionItems: [(name: String, meta: String, dim: Bool)] {
        source == "suggested" ? suggested : frequent
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Anchor used to detect scroll past the large title.
                Color.clear
                    .frame(height: 0)
                    .id("plan-scroll-top")

                header
                quickActions
                    .padding(.top, 14)
                    .padding(.bottom, 4)

                VStack(alignment: .leading, spacing: 0) {
                    workList
                    // Hide alternate-session picker while a workout is in progress.
                    if betterFit.getActiveWorkout() == nil {
                        otherSessions
                    }
                }
                .padding(.horizontal, BFSpacing.pageHorizontal)
                // Clearance for the floating Start workout pill + tab bar.
                .padding(.bottom, 120)
            }
        }
        .modifier(PlanScrollCollapseModifier(isScrolled: $isScrolled))
        .bfBackground(theme: theme)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top, spacing: 0) {
            topBar
        }
        .onAppear(perform: loadPlan)
        .sheet(isPresented: $showAddExercise) {
            AddExerciseSheet(theme: theme) { planned in
                if let targetId = replaceTargetId,
                   let targetIndex = exercises.firstIndex(where: { $0.id == targetId })
                {
                    exercises[targetIndex] = planned
                    replaceTargetId = nil
                } else {
                    exercises.append(planned)
                }
                persistExercises()
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showEquipment) {
            equipmentSheet
                .presentationDetents([.medium])
        }
        .sheet(item: $selectedExercise) { exercise in
            ExerciseDetailSheet(
                exercise: exercise,
                theme: theme,
                onDelete: {
                    exercises.removeAll { $0.id == exercise.id }
                    persistExercises()
                    selectedExercise = nil
                },
                onReplace: {
                    // Swap this exercise in place via the add-exercise picker.
                    replaceTargetId = exercise.id
                    showAddExercise = true
                },
                onSuperset: {
                    // Pair with the next row (or the previous one at the end),
                    // matching the work-list swipe/context-menu behaviour.
                    guard let exerciseIndex = exercises.firstIndex(where: { $0.id == exercise.id }) else { return }
                    if exerciseIndex + 1 < exercises.count {
                        pairSuperset(currentIndex: exerciseIndex, withIndex: exerciseIndex + 1)
                    } else if exerciseIndex > 0 {
                        pairSuperset(currentIndex: exerciseIndex - 1, withIndex: exerciseIndex)
                    }
                },
                onUpdate: { updated in
                    if let exerciseIndex = exercises.firstIndex(where: { $0.id == exercise.id }) {
                        exercises[exerciseIndex] = updated
                        persistExercises()
                    }
                }
            )
            .presentationDetents([.medium, .large])
        }
        .sheet(item: $workoutPreview) { preview in
            WorkoutPreviewScreen(
                theme: theme,
                workout: preview,
                onAdopt: {
                    adoptSession(named: preview.name)
                    if preview.name != sessionName {
                        // If we not a different plan, keep current exercises.
                    }
                    exercises = preview.exercises
                    sessionName = preview.name
                    persistExercises()
                },
                onStart: {
                    adoptSession(named: preview.name)
                    exercises = preview.exercises
                    sessionName = preview.name
                    persistExercises()
                }
            )
        }
    }
}
// MARK: - Scroll collapse (search nav)

private struct PlanScrollCollapseModifier: ViewModifier {
    @Binding var isScrolled: Bool

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content.onScrollGeometryChange(for: Bool.self) { geo in
                geo.contentOffset.y + geo.contentInsets.top > 28
            } action: { _, scrolled in
                guard scrolled != isScrolled else { return }
                withAnimation(.snappy(duration: 0.22)) {
                    isScrolled = scrolled
                }
            }
        } else {
            content.background {
                GeometryReader { geo in
                    Color.clear.preference(
                        key: PlanScrollOffsetKey.self,
                        value: -geo.frame(in: .named("plan-scroll")).minY
                    )
                }
            }
            .coordinateSpace(name: "plan-scroll")
            .onPreferenceChange(PlanScrollOffsetKey.self) { offset in
                let scrolled = offset > 28
                guard scrolled != isScrolled else { return }
                withAnimation(.easeInOut(duration: 0.2)) {
                    isScrolled = scrolled
                }
            }
        }
    }
}

private struct PlanScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    NavigationStack {
        WorkoutHomeView(betterFit: BetterFit(), theme: .defaultTheme, demoMode: true)
    }
    .preferredColorScheme(.dark)
}
