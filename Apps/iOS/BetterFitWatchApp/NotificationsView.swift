import BetterFit
import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var appState: WatchAppState
    @State private var reminderTime = Date()
    @State private var isReminderEnabled = false
    @State private var selectedDays: Set<Int> = []

    private var isGuest: Bool {
        // Check if Supabase is configured and user is not authenticated
        let config = AppConfiguration()
        return config.isSupabaseConfigured && !appState.betterFit.authService.isAuthenticated
    }

    var body: some View {
        List {
            // Guest Sign In Prompt
            if isGuest {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "person.badge.plus")
                                .font(.title3)
                                .foregroundStyle(WatchTheme.accent)

                            Text("Sign In")
                                .font(.headline)
                                .foregroundStyle(WatchTheme.textPrimary)
                        }

                        Text("Sign in on your iPhone to sync reminders across devices.")
                            .font(.caption)
                            .foregroundStyle(WatchTheme.textSecondary)
                    }
                    .padding(.vertical, 4)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(WatchTheme.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(WatchTheme.border, lineWidth: 1)
                        )
                )
            }

            Section {
                Toggle("Workout Reminders", isOn: $isReminderEnabled)
                    .font(.headline)
                    .foregroundStyle(WatchTheme.textPrimary)
                    .tint(WatchTheme.accent)
                    .listRowSeparator(.hidden)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(WatchTheme.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(WatchTheme.border, lineWidth: 1)
                            )
                    )
            }

            if isReminderEnabled {
                Section {
                    DatePicker(
                        "Time",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .tint(WatchTheme.accent)
                    .listRowSeparator(.hidden)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(WatchTheme.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(WatchTheme.border, lineWidth: 1)
                            )
                    )
                } header: {
                    Text("Reminder Time")
                        .font(.caption)
                        .foregroundStyle(WatchTheme.textSecondary)
                }

                Section {
                    ForEach(0..<7) { dayIndex in
                        DayToggleRow(
                            day: dayName(for: dayIndex),
                            isSelected: selectedDays.contains(dayIndex)
                        ) { isSelected in
                            if isSelected {
                                selectedDays.insert(dayIndex)
                            } else {
                                selectedDays.remove(dayIndex)
                            }
                        }
                    }
                } header: {
                    Text("Repeat On")
                        .font(.caption)
                        .foregroundStyle(WatchTheme.textSecondary)
                }

                Section {
                    Button {
                        saveReminders()
                    } label: {
                        Label("Save Reminders", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(WatchTheme.accent)
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Smart Reminders")
                        .font(.caption)
                        .foregroundStyle(WatchTheme.textSecondary)

                    Text(
                        "BetterFit will suggest the best times to work out based on your history and recovery status."
                    )
                    .font(.caption2)
                    .foregroundStyle(WatchTheme.textSecondary)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(WatchTheme.background.ignoresSafeArea())
        .navigationTitle("Reminders")
    }

    private func dayName(for index: Int) -> String {
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return days[index]
    }

    private func saveReminders() {
        // Save reminder settings and schedule notifications
        // This would integrate with the SmartNotificationManager from BetterFit
        appState.betterFit.notificationManager.scheduleNotifications(
            userProfile: appState.betterFit.socialManager.getUserProfile(),
            workoutHistory: appState.betterFit.getWorkoutHistory(),
            activePlan: appState.betterFit.planManager.getActivePlan()
        )
    }
}

struct DayToggleRow: View {
    let day: String
    let isSelected: Bool
    let onToggle: (Bool) -> Void

    var body: some View {
        Button {
            onToggle(!isSelected)
        } label: {
            HStack {
                Text(day)
                    .foregroundStyle(WatchTheme.textPrimary)

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? WatchTheme.accent : WatchTheme.textSecondary)
            }
        }
        .buttonStyle(.plain)
        .listRowSeparator(.hidden)
        .listRowBackground(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(WatchTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(WatchTheme.border, lineWidth: 1)
                )
        )
    }
}
