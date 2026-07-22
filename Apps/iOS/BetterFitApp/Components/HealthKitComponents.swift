import BetterFit
import SwiftUI

/// Observable state manager for HealthKit integration across the app
@Observable
final class HealthKitManager {
    // MARK: - State

    private(set) var isConnected: Bool = false
    private(set) var authorizationStatus: HealthKitService.AuthorizationStatus = .notDetermined
    private(set) var todaySummary: HealthKitService.HealthSummary?
    private(set) var isLoading: Bool = false

    // MARK: - Persistence Keys

    private static let hasRequestedAuthKey = "betterfit.healthkit.hasRequestedAuth"
    private static let dismissedPromptKey = "betterfit.healthkit.dismissedPrompt"

    var hasRequestedAuthorization: Bool {
        get { UserDefaults.standard.bool(forKey: Self.hasRequestedAuthKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.hasRequestedAuthKey) }
    }

    var hasDismissedPrompt: Bool {
        get { UserDefaults.standard.bool(forKey: Self.dismissedPromptKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.dismissedPromptKey) }
    }

    // MARK: - Dependencies

    private let healthKitService: HealthKitService

    // MARK: - Computed Properties

    var isAvailable: Bool {
        healthKitService.isAvailable
    }

    var shouldShowConnectionPrompt: Bool {
        isAvailable && !isConnected && !hasDismissedPrompt
    }

    // MARK: - Initialization

    init(healthKitService: HealthKitService) {
        self.healthKitService = healthKitService
        // Check if we previously connected
        if hasRequestedAuthorization {
            isConnected = true
            authorizationStatus = .authorized
        }
    }

    // MARK: - Actions

    @MainActor
    func requestAuthorization() async {
        guard isAvailable else {
            authorizationStatus = .unavailable
            return
        }

        isLoading = true
        defer { isLoading = false }

        let status = await healthKitService.requestAuthorization()
        authorizationStatus = status

        if status == .authorized {
            isConnected = true
            hasRequestedAuthorization = true
            // Fetch initial data
            await refreshHealthData()
        }
    }

    @MainActor
    func refreshHealthData() async {
        guard isConnected else { return }

        isLoading = true
        defer { isLoading = false }

        todaySummary = await healthKitService.fetchTodaySummary()
    }

    func dismissPrompt() {
        hasDismissedPrompt = true
    }

    func resetPromptDismissal() {
        hasDismissedPrompt = false
    }
}

// MARK: - Apple Health Connection Card

struct AppleHealthConnectionCard: View {
    @Environment(\.colorScheme) var colorScheme
    let theme: AppTheme
    let healthKitManager: HealthKitManager
    let showDismiss: Bool

    @State private var isConnecting = false

    init(theme: AppTheme, healthKitManager: HealthKitManager, showDismiss: Bool = true) {
        self.theme = theme
        self.healthKitManager = healthKitManager
        self.showDismiss = showDismiss
    }

    var body: some View {
        BFCard(theme: theme) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(theme.accent.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: "heart.fill")
                        .font(.title3)
                        .foregroundStyle(theme.accent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Connect Apple Health")
                        .font(.subheadline.weight(.semibold))

                    Text("Sync workouts, track steps, and monitor heart rate")
                        .font(.caption)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                if isConnecting || healthKitManager.isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Button("Connect") {
                        connect()
                    }
                    .buttonStyle(BFPrimaryButtonStyle(isFullWidth: false))
                }
            }

            if showDismiss {
                HStack {
                    Spacer()
                    Button {
                        healthKitManager.dismissPrompt()
                    } label: {
                        Text("Not now")
                            .font(.caption)
                            .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    private func connect() {
        isConnecting = true
        Task {
            await healthKitManager.requestAuthorization()
            isConnecting = false
        }
    }
}

// MARK: - Apple Health Connected Badge

struct AppleHealthConnectedBadge: View {
    @Environment(\.colorScheme) var colorScheme
    let theme: AppTheme

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "heart.fill")
                .font(.caption2)
                .foregroundStyle(BFColors.success)

            Text("Apple Health Connected")
                .font(.caption2.weight(.medium))
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background {
            Capsule().fill(BFColors.surfaceRaised(for: colorScheme))
        }
        .overlay {
            Capsule().stroke(BFColors.border(for: colorScheme), lineWidth: 1)
        }
    }
}

// MARK: - Health Stats Row (for Profile)

struct HealthStatsFromAppleHealth: View {
    @Environment(\.colorScheme) var colorScheme
    let theme: AppTheme
    let summary: HealthKitService.HealthSummary

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
            ],
            spacing: 12
        ) {
            // Activity metrics
            healthStatCard(
                icon: "figure.walk",
                label: "Steps",
                value: formatSteps(summary.steps),
                subtitle: "Today",
                color: .green,
                source: "Apple Health"
            )
            healthStatCard(
                icon: "flame.fill",
                label: "Active Cal",
                value: formatCalories(summary.activeEnergy),
                subtitle: "Today",
                color: .orange,
                source: "Apple Health"
            )
            healthStatCard(
                icon: "figure.walk.motion",
                label: "Distance",
                value: formatDistance(summary.distanceWalkingRunning),
                subtitle: "Today",
                color: .cyan,
                source: "Apple Health"
            )
            healthStatCard(
                icon: "stairs",
                label: "Flights",
                value: "\(Int(summary.flightsClimbed))",
                subtitle: "Climbed",
                color: .purple,
                source: "Apple Health"
            )

            // Heart metrics
            if let heartRate = summary.heartRate {
                healthStatCard(
                    icon: "heart.fill",
                    label: "Heart Rate",
                    value: "\(Int(heartRate))",
                    subtitle: "bpm avg",
                    color: .red,
                    source: "Apple Health"
                )
            }
            if let restingHR = summary.restingHeartRate {
                healthStatCard(
                    icon: "heart.circle",
                    label: "Resting HR",
                    value: "\(Int(restingHR))",
                    subtitle: "bpm",
                    color: .pink,
                    source: "Apple Health"
                )
            }

            // Body metrics
            if let bmi = summary.bmi {
                healthStatCard(
                    icon: "figure.stand",
                    label: "BMI",
                    value: String(format: "%.1f", bmi),
                    subtitle: bmiCategory(bmi),
                    color: bmiColor(bmi),
                    source: "Apple Health"
                )
            }
            if let height = summary.height {
                healthStatCard(
                    icon: "ruler",
                    label: "Height",
                    value: formatHeight(height),
                    subtitle: "",
                    color: .blue,
                    source: "Apple Health"
                )
            }
            if let bodyMass = summary.bodyMass {
                healthStatCard(
                    icon: "scalemass.fill",
                    label: "Weight",
                    value: formatWeight(bodyMass),
                    subtitle: "",
                    color: .indigo,
                    source: "Apple Health"
                )
            }
            if let bodyFat = summary.bodyFatPercentage {
                healthStatCard(
                    icon: "percent",
                    label: "Body Fat",
                    value: String(format: "%.1f%%", bodyFat * 100),
                    subtitle: "",
                    color: .brown,
                    source: "Apple Health"
                )
            }

            // Other metrics
            if let oxygen = summary.oxygenSaturation {
                healthStatCard(
                    icon: "lungs.fill",
                    label: "Blood O₂",
                    value: String(format: "%.0f%%", oxygen * 100),
                    subtitle: "",
                    color: .teal,
                    source: "Apple Health"
                )
            }
            if let sleepHours = summary.sleepHours {
                healthStatCard(
                    icon: "moon.zzz.fill",
                    label: "Sleep",
                    value: formatSleep(sleepHours),
                    subtitle: "Last Night",
                    color: .indigo,
                    source: "Apple Health"
                )
            }
            if let standHours = summary.standHours {
                healthStatCard(
                    icon: "figure.stand",
                    label: "Stand Hours",
                    value: "\(standHours)",
                    subtitle: "of 12",
                    color: .mint,
                    source: "Apple Health"
                )
            }
        }
    }

    @ViewBuilder
    private func healthStatCard(
        icon: String, label: String, value: String, subtitle: String, color: Color, source: String
    ) -> some View {
        BFCard(theme: theme) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(color)

                    Text(label)
                        .font(.caption)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                }

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.title2.weight(.bold))
                        .monospacedDigit()

                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(color)
                    }
                }

                Text(source)
                    .font(.caption2)
                    .foregroundStyle(BFColors.textTertiary(for: colorScheme))
            }
        }
    }

    // MARK: - Formatting Helpers

    private func formatSteps(_ steps: Double) -> String {
        if steps >= 1000 {
            return String(format: "%.1fK", steps / 1000)
        }
        return "\(Int(steps))"
    }

    private func formatCalories(_ calories: Double) -> String {
        if calories >= 1000 {
            return String(format: "%.1fK", calories / 1000)
        }
        return "\(Int(calories))"
    }

    private func formatDistance(_ meters: Double) -> String {
        let miles = meters / 1609.34
        if miles >= 1 {
            return String(format: "%.1f mi", miles)
        } else {
            let feet = meters * 3.28084
            return String(format: "%.0f ft", feet)
        }
    }

    private func formatHeight(_ meters: Double) -> String {
        let totalInches = meters * 39.3701
        let feet = Int(totalInches / 12)
        let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
        return "\(feet)'\(inches)\""
    }

    private func formatWeight(_ kg: Double) -> String {
        let lbs = kg * 2.20462
        return String(format: "%.0f lbs", lbs)
    }

    private func formatSleep(_ hours: Double) -> String {
        let h = Int(hours)
        let m = Int((hours - Double(h)) * 60)
        if m > 0 {
            return "\(h)h \(m)m"
        }
        return "\(h)h"
    }

    private func bmiCategory(_ bmi: Double) -> String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }

    private func bmiColor(_ bmi: Double) -> Color {
        switch bmi {
        case ..<18.5: return .yellow
        case 18.5..<25: return .green
        case 25..<30: return .orange
        default: return .red
        }
    }
}

// MARK: - Notification Center Reminder

struct AppleHealthReminderBanner: View {
    @Environment(\.colorScheme) var colorScheme
    let theme: AppTheme
    let healthKitManager: HealthKitManager

    @State private var isConnecting = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.circle.fill")
                .font(.title2)
                .foregroundStyle(theme.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text("Sync with Apple Health")
                    .font(.caption.weight(.semibold))

                Text("Track your workouts automatically")
                    .font(.caption2)
                    .foregroundStyle(BFColors.textSecondary(for: colorScheme))
            }

            Spacer(minLength: 0)

            if isConnecting || healthKitManager.isLoading {
                ProgressView()
                    .controlSize(.small)
            } else {
                Button {
                    connect()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(theme.accent)
                }
            }

            Button {
                healthKitManager.dismissPrompt()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BFColors.textSecondary(for: colorScheme))
            }
        }
        .padding(12)
        .background {
            let shape = RoundedRectangle(cornerRadius: 12, style: .continuous)
            shape.fill(BFColors.surface(for: colorScheme))
                .overlay { shape.stroke(BFColors.border(for: colorScheme), lineWidth: 1) }
        }
    }

    private func connect() {
        isConnecting = true
        Task {
            await healthKitManager.requestAuthorization()
            isConnecting = false
        }
    }
}
