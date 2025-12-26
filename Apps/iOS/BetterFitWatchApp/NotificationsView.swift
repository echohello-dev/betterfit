import BetterFit
import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var appState: WatchAppState
    @State private var reminderTime = Date()
    @State private var isReminderEnabled = false
    @State private var selectedDays: Set<Int> = []

    var body: some View {
        List {
            Section {
                Toggle("Workout Reminders", isOn: $isReminderEnabled)
                    .font(.headline)
            }

            if isReminderEnabled {
                Section {
                    DatePicker(
                        "Time",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                } header: {
                    Text("Reminder Time")
                        .font(.caption)
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
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Smart Reminders")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(
                        "BetterFit will suggest the best times to work out based on your history and recovery status."
                    )
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            }
        }
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
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .green : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}
