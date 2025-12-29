import BetterFit
import SwiftUI

@main
struct BetterFitApp: App {
    @StateObject private var authService: AuthService
    @State private var betterFit: BetterFit?
    @State private var showSignIn = false
    @State private var showConfigWarning = true

    @AppStorage(AppTheme.storageKey) private var storedTheme: String = AppTheme.defaultTheme
        .rawValue
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    private let config: AppConfiguration

    init() {
        // Load application configuration from environment
        let config = AppConfiguration()
        self.config = config

        // Initialize Supabase auth service with configuration
        let url = config.getSupabaseURL()
        let key = config.getSupabaseAnonKey()

        _authService = StateObject(
            wrappedValue: AuthService(
                supabaseURL: url,
                supabaseAnonKey: key
            ))
    }

    var body: some Scene {
        WindowGroup {
            let theme = AppTheme.fromStorage(storedTheme)

            Group {
                if !hasCompletedOnboarding || showSignIn {
                    // Show sign in screen
                    SignInView(
                        theme: theme,
                        onSignIn: { idToken, nonce in
                            guard config.isSupabaseConfigured else {
                                // Supabase not configured - ignore sign in attempt
                                return
                            }
                            try await authService.signInWithApple(
                                idToken: idToken, nonce: nonce)
                            await migrateGuestDataIfNeeded()
                            hasCompletedOnboarding = true
                            showSignIn = false
                        },
                        onEmailSignIn: { email, password in
                            guard config.isSupabaseConfigured else {
                                // Supabase not configured - ignore sign in attempt
                                return
                            }
                            try await authService.signInWithEmail(
                                email: email, password: password)
                            await migrateGuestDataIfNeeded()
                            hasCompletedOnboarding = true
                            showSignIn = false
                        },
                        onGuestMode: {
                            authService.continueAsGuest()
                            hasCompletedOnboarding = true
                            showSignIn = false
                            initializeBetterFitWithLocalPersistence()
                        }
                    )
                    .safeAreaInset(edge: .bottom) {
                        VStack(spacing: 12) {
                            // Show configuration warning if present (above bottom area)
                            if !config.warnings.isEmpty && showConfigWarning {
                                configWarningBanner(
                                    icon: "exclamationmark.circle.fill",
                                    message: config.primaryWarning ?? "Configuration issue",
                                    color: .orange,
                                    theme: theme
                                )
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                } else if let betterFit {
                    // Show main app
                    RootTabView(betterFit: betterFit, theme: theme)
                        .tint(theme.accent)
                        .preferredColorScheme(theme.preferredColorScheme)
                        .overlay(alignment: .bottom) {
                            // Show warning banner above Start Workout button if guest mode
                            if !config.isSupabaseConfigured && showConfigWarning {
                                configWarningBanner(
                                    icon: "info.circle.fill",
                                    message: "Running in guest mode. Cloud features are disabled.",
                                    color: .blue,
                                    theme: theme
                                )
                                .padding(.horizontal, 16)
                                .padding(.bottom, 126)  // Above Start Workout button + tab bar
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                } else {
                    // Loading state
                    ZStack {
                        theme.backgroundGradient.ignoresSafeArea()
                        ProgressView()
                            .tint(theme.accent)
                            .scaleEffect(1.5)
                    }
                }
            }
            .task {
                // If Supabase is not configured, default to guest mode
                if !config.isSupabaseConfigured {
                    authService.continueAsGuest()
                    initializeBetterFitWithLocalPersistence()
                    hasCompletedOnboarding = true
                } else {
                    // Setup auth state listener for Supabase-enabled builds
                    authService.setupAuthStateListener()

                    // Initialize BetterFit based on auth state
                    if authService.isAuthenticated {
                        initializeBetterFitWithSupabasePersistence()
                    } else if authService.isGuest {
                        initializeBetterFitWithLocalPersistence()
                    }
                }
            }
            .onChange(of: authService.isAuthenticated) { _, isAuthenticated in
                if isAuthenticated && config.isSupabaseConfigured {
                    Task {
                        await migrateGuestDataIfNeeded()
                        initializeBetterFitWithSupabasePersistence()
                    }
                }
            }
        }
    }

    // MARK: - BetterFit Initialization

    private func initializeBetterFitWithLocalPersistence() {
        let localPersistence = LocalPersistenceService()
        betterFit = BetterFit(persistenceService: localPersistence)
    }

    private func initializeBetterFitWithSupabasePersistence() {
        let supabasePersistence = SupabasePersistenceService(supabaseClient: authService.client)
        betterFit = BetterFit(persistenceService: supabasePersistence)
    }

    // MARK: - Data Migration

    private func migrateGuestDataIfNeeded() async {
        guard authService.isAuthenticated else { return }

        // Get guest data
        let localPersistence = LocalPersistenceService()

        do {
            // Check if there's any guest data to migrate
            let workouts = try await localPersistence.getWorkouts()
            guard !workouts.isEmpty else { return }

            // Migrate to Supabase
            let supabasePersistence = SupabasePersistenceService(supabaseClient: authService.client)

            // Migrate workouts
            for workout in workouts {
                try await supabasePersistence.saveWorkout(workout)
            }

            // Migrate templates
            let templates = try await localPersistence.getTemplates()
            for template in templates {
                try await supabasePersistence.saveTemplate(template)
            }

            // Migrate plans
            let plans = try await localPersistence.getPlans()
            for plan in plans {
                try await supabasePersistence.savePlan(plan)
            }

            // Migrate user profile
            if let profile = try await localPersistence.getUserProfile() {
                try await supabasePersistence.saveUserProfile(profile)
            }

            // Migrate body map recovery
            if let recovery = try await localPersistence.getBodyMapRecovery() {
                try await supabasePersistence.saveBodyMapRecovery(recovery)
            }

            // Migrate streak data
            let streakData = try await localPersistence.getStreakData()
            try await supabasePersistence.saveStreakData(
                currentStreak: streakData.currentStreak,
                longestStreak: streakData.longestStreak,
                lastWorkoutDate: streakData.lastWorkoutDate
            )

            // Don't clear guest data yet (keep as backup per ADR)
            // try await localPersistence.clearAllData()

            print("Successfully migrated guest data to Supabase")
        } catch {
            print("Failed to migrate guest data: \(error)")
        }
    }

    // MARK: - Configuration Warning Banner

    @ViewBuilder
    private func configWarningBanner(
        icon: String,
        message: String,
        color: Color,
        theme: AppTheme
    ) -> some View {
        let shape = RoundedRectangle(cornerRadius: 27, style: .continuous)

        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.body)

            Text(message)
                .font(.caption)
                .foregroundStyle(.white)
                .lineLimit(2)

            Spacer(minLength: 0)

            Button {
                withAnimation {
                    showConfigWarning = false
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.white.opacity(0.6))
                    .font(.body)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background {
            if #available(iOS 26.0, *) {
                shape
                    .fill(color.opacity(0.2))
                    .glassEffect(.regular.interactive(), in: shape)
            } else {
                shape
                    .fill(color.opacity(0.2))
                    .overlay { shape.stroke(color.opacity(0.3), lineWidth: 1) }
                    .shadow(
                        color: Color.black.opacity(0.22),
                        radius: 14,
                        x: 0,
                        y: 6
                    )
            }
        }
    }
}
