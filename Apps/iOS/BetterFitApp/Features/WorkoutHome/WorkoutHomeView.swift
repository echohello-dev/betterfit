import BetterFit
import SwiftUI

// swiftlint:disable file_length type_body_length identifier_name

struct WorkoutHomeView: View {
    let betterFit: BetterFit
    let theme: AppTheme

    let demoModeOverride: Bool?

    #if DEBUG
        @AppStorage("betterfit.workoutHome.demoMode") var demoModeEnabled = false
    #else
        var demoModeEnabled: Bool { false }
    #endif

    @State var demoBetterFit: BetterFit = BetterFit()
    @State var didSeedDemoData = false

    @State var selectedRegion: BodyRegion = .core
    @State var statuses: [BodyRegion: RecoveryStatus] = [:]

    @State var showCalendar = false
    @State var selectedDate = Date.now

    @State var showStreakSummary = false

    @State var didAutoScrollStreakToToday = false

    // Workout card selection
    @State var selectedWorkoutIndex: Int = 0
    @State var cardSwipeOffset: CGFloat = 0
    @State var showEquipmentSwapSheet = false
    @State var availableEquipment: Set<Equipment> = Set(Equipment.allCases)
    @State var activeWorkoutId: UUID?  // Track active workout for view updates

    // Gamification
    @State var currentStreak = 0
    @State var longestStreak = 0
    @State var lastWorkoutDate: Date?
    @State var username: String = "User"

    // Activity heatmap (GitHub-style)
    @State var activityByDay: [Date: Int] = [:]

    @State var heatmapRange: HeatmapRange = .year
    @State var showCustomRangeSheet = false
    @State var customRangeStart: Date =
        Calendar.current.date(byAdding: .year, value: -3, to: Date.now) ?? Date.now
    @State var customRangeEnd: Date = Date.now

    init(betterFit: BetterFit, theme: AppTheme, demoMode: Bool? = nil) {
        self.betterFit = betterFit
        self.theme = theme
        self.demoModeOverride = demoMode
    }

    var isDemoMode: Bool {
        demoModeOverride ?? demoModeEnabled
    }

    var bf: BetterFit {
        isDemoMode ? demoBetterFit : betterFit
    }

    var hasActiveWorkout: Bool {
        bf.getActiveWorkout() != nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: hasActiveWorkout ? 12 : 20) {
                // Welcome Section (compact when active workout)
                if hasActiveWorkout {
                    compactWelcomeSection
                } else {
                    welcomeSection
                }

                // Overview (summary + gauge) - hide when active workout
                if !hasActiveWorkout {
                    workoutOverviewSection
                }

                // Streak + Vitals (compact when active workout)
                if hasActiveWorkout {
                    compactStreakSection
                } else {
                    streakVitalsSection
                    // Swipeable Workout Cards
                    workoutCardStack
                }

                // Workout Preview for selected card
                workoutPreviewSection

                Spacer(minLength: 8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 100)  // Space for floating nav bar
        }
        .background(theme.backgroundGradient.ignoresSafeArea())
        .sheet(isPresented: $showCalendar) {
            CalendarSheetView(selectedDate: $selectedDate, theme: theme)
                .presentationDetents([PresentationDetent.medium, PresentationDetent.large])
        }
        .sheet(isPresented: $showStreakSummary) {
            StreakSummarySheetView(
                betterFit: bf,
                selectedDate: $selectedDate,
                theme: theme,
                openCalendar: { showCalendar = true }
            )
            .presentationDetents([PresentationDetent.medium, PresentationDetent.large])
        }
        .sheet(isPresented: $showCustomRangeSheet) {
            CustomHeatmapRangeSheet(
                theme: theme,
                start: $customRangeStart,
                end: $customRangeEnd
            )
            .presentationDetents([PresentationDetent.medium])
        }
        .sheet(isPresented: $showEquipmentSwapSheet) {
            EquipmentSwapSheet(
                theme: theme,
                availableEquipment: $availableEquipment,
                onApply: { applyEquipmentSwaps() }
            )
            .presentationDetents([PresentationDetent.medium, PresentationDetent.large])
        }
        .onAppear {
            ensureDemoSeededIfNeeded()
            refreshStatuses()
            loadGameStats()
            refreshVitals()
            refreshActiveWorkout()
        }
        .onReceive(NotificationCenter.default.publisher(for: .workoutStarted)) { _ in
            refreshActiveWorkout()
        }
        .onReceive(NotificationCenter.default.publisher(for: .workoutCompleted)) { _ in
            refreshActiveWorkout()
            refreshStatuses()
            loadGameStats()
            refreshVitals()
        }
        #if DEBUG
            .onChange(of: demoModeEnabled) {
                ensureDemoSeededIfNeeded()
                refreshStatuses()
                loadGameStats()
                refreshVitals()
            }
        #endif
        .onChange(of: heatmapRange) {
            refreshVitals()
        }
        .onChange(of: customRangeStart) {
            if heatmapRange == .custom {
                refreshVitals()
            }
        }
        .onChange(of: customRangeEnd) {
            if heatmapRange == .custom {
                refreshVitals()
            }
        }
    }

    @ViewBuilder
    private var toolbarContent: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: 16) {
                toolbarButtons
            }
        } else {
            toolbarButtons
        }
    }

    @ViewBuilder
    private var toolbarButtons: some View {
        HStack(spacing: 10) {
            #if DEBUG
                if demoModeOverride == nil {
                    Menu {
                        Toggle(isOn: $demoModeEnabled) {
                            Label("Demo Mode", systemImage: "testtube.2")
                        }
                    } label: {
                        Image(systemName: isDemoMode ? "testtube.2" : "testtube.2")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(isDemoMode ? theme.accent : .secondary)
                            .frame(width: 34, height: 34)
                            .background {
                                Circle().fill(theme.cardBackground)
                            }
                            .overlay {
                                Circle().stroke(theme.cardStroke, lineWidth: 1)
                            }
                    }
                }
            #endif
            BFChromeIconButton(
                systemImage: "chart.bar.fill",
                accessibilityLabel: "Stats",
                theme: theme
            ) {
                // Show stats
            }
        }
    }
}
