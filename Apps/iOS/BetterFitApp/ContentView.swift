import BetterFit
import SwiftUI

struct ContentView: View {
    let betterFit: BetterFit

    let theme: AppTheme

    @State private var lastEvent: String = ""
    @State private var recoveryPercent: Double = 0

    @AppStorage(AppTheme.storageKey) private var storedTheme: String = AppTheme.classic.rawValue

    @State private var showingThemePicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    recoveryCard

                    metricsRow

                    actionsCard

                    if !lastEvent.isEmpty {
                        BFCard(theme: theme) {
                            HStack(alignment: .firstTextBaseline, spacing: 12) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(theme.accent)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Last event")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(lastEvent)
                                        .font(.body.weight(.semibold))
                                }
                                Spacer(minLength: 0)
                            }
                        }
                    }

                    BFCard(theme: theme) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Suggestions")
                                .font(.headline)
                            Text(
                                "Next, we can add per-muscle recovery, a weekly load trend, and a real workout log. This dashboard is designed to scale as features land."
                            )
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(16)
            }
            .background(theme.backgroundGradient.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingThemePicker = true
                    } label: {
                        Image(systemName: "paintpalette")
                    }
                    .accessibilityLabel("Change theme")
                }
            }
            .sheet(isPresented: $showingThemePicker) {
                ThemePickerView(
                    selectedTheme: Binding(
                        get: { AppTheme.fromStorage(storedTheme) },
                        set: { storedTheme = $0.rawValue }
                    )
                )
                .presentationDetents([.medium, .large])
            }
        }
        .onAppear {
            refreshRecovery()
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("BetterFit")
                    .font(.largeTitle.weight(.bold))
                Text("Recovery dashboard")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Button {
                refreshRecovery()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.body.weight(.semibold))
                    .padding(10)
                    .background(theme.cardBackground)
                    .clipShape(Circle())
                    .overlay {
                        Circle().stroke(theme.cardStroke, lineWidth: 1)
                    }
            }
            .accessibilityLabel("Refresh")
        }
    }

    private var recoveryCard: some View {
        BFCard(theme: theme) {
            HStack(spacing: 16) {
                ZStack {
                    ProgressRing(progress: recoveryPercent / 100.0, lineWidth: 10, theme: theme)
                        .frame(width: 86, height: 86)
                    VStack(spacing: 2) {
                        Text("\(Int(recoveryPercent))%")
                            .font(.title3.weight(.bold))
                            .monospacedDigit()
                        Text("Recovery")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Overall recovery")
                        .font(.headline)
                    Text(recoveryDescription)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }
        }
    }

    private var metricsRow: some View {
        HStack(spacing: 12) {
            MetricPill(
                title: "Readiness",
                value: readinessLabel,
                systemImage: "bolt.heart",
                theme: theme
            )

            MetricPill(
                title: "Today",
                value: "\(Date.now.formatted(date: .abbreviated, time: .omitted))",
                systemImage: "calendar",
                theme: theme
            )
        }
    }

    private var actionsCard: some View {
        BFCard(theme: theme) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick actions")
                    .font(.headline)

                Button {
                    simulateWorkout()
                } label: {
                    Label(
                        "Simulate workout + update recovery",
                        systemImage: "figure.strengthtraining.traditional"
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    lastEvent = ""
                } label: {
                    Label("Clear last event", systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var recoveryDescription: String {
        switch recoveryPercent {
        case 0..<35:
            return "Low recovery — consider lighter work or extra rest."
        case 35..<70:
            return "Moderate recovery — train, but manage intensity."
        default:
            return "High recovery — good day for pushing performance."
        }
    }

    private var readinessLabel: String {
        switch recoveryPercent {
        case 0..<35:
            return "Low"
        case 35..<70:
            return "OK"
        default:
            return "High"
        }
    }

    private func refreshRecovery() {
        recoveryPercent = betterFit.bodyMapManager.getOverallRecoveryPercentage()
    }

    private func simulateWorkout() {
        // Minimal "fake" workout flow just to prove the library runs in an app.
        let benchPress = Exercise(
            name: "Bench Press",
            equipmentRequired: .barbell,
            muscleGroups: [.chest, .triceps]
        )

        let workout = Workout(
            name: "Quick Session",
            exercises: [
                WorkoutExercise(exercise: benchPress, sets: [ExerciseSet(reps: 8, weight: 60)])
            ]
        )

        betterFit.startWorkout(workout)
        betterFit.completeWorkout(workout)

        lastEvent = "Completed workout"
        refreshRecovery()
    }
}

#Preview {
    ContentView(betterFit: BetterFit(), theme: .midnight)
}
