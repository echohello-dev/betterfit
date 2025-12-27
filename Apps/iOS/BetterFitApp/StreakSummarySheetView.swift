import BetterFit
import HealthKit
import SwiftUI

struct StreakSummarySheetView: View {
    let betterFit: BetterFit
    @Binding var selectedDate: Date
    let theme: AppTheme
    let openCalendar: () -> Void

    @StateObject private var viewModel = HealthKitStreakSummaryViewModel()

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(weekTitle)
                            .bfHeading(theme: theme, size: 18, relativeTo: .headline)

                        HStack(spacing: 12) {
                            summaryPill(
                                title: "BetterFit",
                                value: "\(betterFitWorkouts.count)",
                                systemImage: "figure.strengthtraining.traditional"
                            )

                            summaryPill(
                                title: "Apple Health",
                                value: appleHealthCountText,
                                systemImage: "heart.text.square"
                            )

                            summaryPill(
                                title: "Time",
                                value: totalTimeText,
                                systemImage: "clock"
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Workouts Done") {
                    if betterFitWorkouts.isEmpty {
                        Text("No BetterFit workouts in this week.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(betterFitWorkouts) { workout in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(workout.name)
                                    .font(.subheadline.weight(.semibold))

                                Text(betterFitWorkoutSubtitle(workout))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Section("Apple Health") {
                    appleHealthSection
                }

                Section {
                    Button {
                        openCalendar()
                    } label: {
                        Label("Pick a date…", systemImage: "calendar")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(theme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Streak Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: shareText) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.body.weight(.semibold))
                    }
                    .accessibilityLabel("Share summary")
                }
            }
        }
        .onAppear {
            viewModel.refresh(range: weekRange)
        }
        .onChange(of: selectedDate) {
            viewModel.refresh(range: weekRange)
        }
    }

    // MARK: - Data

    private var weekRange: DateInterval {
        let calendar = sundayFirstCalendar
        let start = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start
            ?? calendar.startOfDay(for: selectedDate)
        let end = calendar.date(byAdding: .day, value: 7, to: start) ?? start
        return DateInterval(start: start, end: end)
    }

    private var weekTitle: String {
        let start = weekRange.start
        let end = Calendar.current.date(byAdding: .day, value: 6, to: start) ?? start
        return "\(start.formatted(date: .abbreviated, time: .omitted)) – \(end.formatted(date: .abbreviated, time: .omitted))"
    }

    private var betterFitWorkouts: [Workout] {
        betterFit
            .getWorkoutHistory()
            .filter { weekRange.contains($0.date) }
            .sorted(by: { $0.date > $1.date })
    }

    private var appleHealthCountText: String {
        switch viewModel.accessState {
        case .unavailable:
            return "—"
        case .notDetermined:
            return "?"
        case .denied:
            return "0"
        case .authorized:
            return "\(viewModel.workouts.count)"
        }
    }

    private var totalTimeText: String {
        let bf = betterFitWorkouts.compactMap { $0.duration }.reduce(0, +)
        let hk = viewModel.workouts.reduce(0) { $0 + $1.duration }
        let total = bf + hk
        return formatDuration(total)
    }

    private var shareText: String {
        var lines: [String] = []
        lines.append("BetterFit – Streak Summary")
        lines.append(weekTitle)
        lines.append("")

        lines.append("Workouts done (BetterFit): \(betterFitWorkouts.count)")

        if !betterFitWorkouts.isEmpty {
            for w in betterFitWorkouts.prefix(8) {
                lines.append("• \(w.name) — \(betterFitWorkoutSubtitle(w))")
            }
            if betterFitWorkouts.count > 8 {
                lines.append("• …and \(betterFitWorkouts.count - 8) more")
            }
        }

        lines.append("")

        switch viewModel.accessState {
        case .unavailable:
            lines.append("Apple Health: unavailable")
        case .notDetermined:
            lines.append("Apple Health: not connected")
        case .denied:
            lines.append("Apple Health: access denied")
        case .authorized:
            lines.append("Apple Health workouts: \(viewModel.workouts.count)")
            if !viewModel.workouts.isEmpty {
                for w in viewModel.workouts.prefix(8) {
                    lines.append("• \(w.activityName) — \(w.timeRangeText)")
                }
                if viewModel.workouts.count > 8 {
                    lines.append("• …and \(viewModel.workouts.count - 8) more")
                }
            }
        }

        lines.append("")
        lines.append("Total time: \(totalTimeText)")

        return lines.joined(separator: "\n")
    }

    private var sundayFirstCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone.current
        calendar.firstWeekday = 1  // Sunday
        return calendar
    }

    // MARK: - Sections

    @ViewBuilder
    private var appleHealthSection: some View {
        switch viewModel.accessState {
        case .unavailable:
            Text("Apple Health isn’t available on this device.")
                .foregroundStyle(.secondary)

        case .notDetermined:
            VStack(alignment: .leading, spacing: 10) {
                Text("Connect Apple Health to show captured workout times and durations.")
                    .foregroundStyle(.secondary)

                Button {
                    Task { await viewModel.requestAccessAndRefresh(range: weekRange) }
                } label: {
                    Label("Connect Apple Health", systemImage: "heart.text.square")
                }
            }
            .padding(.vertical, 4)

        case .denied:
            VStack(alignment: .leading, spacing: 8) {
                Text("Apple Health access is denied. Enable it in Settings → Privacy & Security → Health.")
                    .foregroundStyle(.secondary)

                if let msg = viewModel.lastErrorMessage {
                    Text(msg)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)

        case .authorized:
            if viewModel.workouts.isEmpty {
                Text("No Apple Health workouts found for this week.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.workouts) { workout in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(workout.activityName)
                            .font(.subheadline.weight(.semibold))

                        Text(workout.timeRangeText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - UI

    private func summaryPill(title: String, value: String, systemImage: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .foregroundStyle(theme.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.regularMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(theme.cardStroke, lineWidth: 1)
                }
        }
    }

    // MARK: - Formatting

    private func betterFitWorkoutSubtitle(_ workout: Workout) -> String {
        var parts: [String] = []
        parts.append(workout.date.formatted(date: .omitted, time: .shortened))

        if let duration = workout.duration, duration > 0 {
            parts.append(formatDuration(duration))
        } else {
            parts.append("duration unknown")
        }

        return parts.joined(separator: " • ")
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let total = Int(max(0, seconds))
        let minutes = total / 60
        let hours = minutes / 60
        let mins = minutes % 60

        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(minutes)m"
    }
}

@MainActor
final class HealthKitStreakSummaryViewModel: ObservableObject {
    enum AccessState {
        case unavailable
        case notDetermined
        case denied
        case authorized
    }

    struct HealthWorkoutSummary: Identifiable {
        let id: UUID
        let activityName: String
        let startDate: Date
        let endDate: Date
        let duration: TimeInterval
        let sourceName: String?

        var timeRangeText: String {
            let start = startDate.formatted(date: .omitted, time: .shortened)
            let end = endDate.formatted(date: .omitted, time: .shortened)
            let minutes = Int(max(0, duration) / 60)
            return "\(start)–\(end) • \(minutes)m" + (sourceName.map { " • \($0)" } ?? "")
        }
    }

    @Published private(set) var accessState: AccessState = .unavailable
    @Published private(set) var workouts: [HealthWorkoutSummary] = []
    @Published private(set) var lastErrorMessage: String?

    private let healthStore = HKHealthStore()

    func refresh(range: DateInterval) {
        updateAccessState()

        guard accessState == .authorized else {
            workouts = []
            return
        }

        fetchWorkouts(range: range)
    }

    func requestAccessAndRefresh(range: DateInterval) async {
        guard HKHealthStore.isHealthDataAvailable() else {
            accessState = .unavailable
            return
        }

        let typesToRead: Set<HKObjectType> = [HKObjectType.workoutType()]

        do {
            try await requestAuthorization(toShare: [], read: typesToRead)
            updateAccessState()
            fetchWorkouts(range: range)
        } catch {
            lastErrorMessage = error.localizedDescription
            updateAccessState()
        }
    }

    private func updateAccessState() {
        guard HKHealthStore.isHealthDataAvailable() else {
            accessState = .unavailable
            return
        }

        let status = healthStore.authorizationStatus(for: HKObjectType.workoutType())
        switch status {
        case .notDetermined:
            accessState = .notDetermined
        case .sharingDenied:
            accessState = .denied
        case .sharingAuthorized:
            accessState = .authorized
        @unknown default:
            accessState = .notDetermined
        }
    }

    private func fetchWorkouts(range: DateInterval) {
        let sampleType = HKObjectType.workoutType()
        let predicate = HKQuery.predicateForSamples(withStart: range.start, end: range.end, options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sort]
        ) { [weak self] _, samples, error in
            Task { @MainActor in
                guard let self else { return }
                if let error {
                    self.lastErrorMessage = error.localizedDescription
                    self.workouts = []
                    return
                }

                let workouts = (samples as? [HKWorkout]) ?? []
                self.workouts = workouts.map { wk in
                    HealthWorkoutSummary(
                        id: wk.uuid,
                        activityName: wk.workoutActivityType.displayName,
                        startDate: wk.startDate,
                        endDate: wk.endDate,
                        duration: wk.duration,
                        sourceName: wk.sourceRevision.source.name
                    )
                }
            }
        }

        healthStore.execute(query)
    }

    private func requestAuthorization(toShare shareTypes: Set<HKSampleType>, read readTypes: Set<HKObjectType>) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                if success {
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit authorization failed"]))
                }
            }
        }
    }
}

private extension HKWorkoutActivityType {
    var displayName: String {
        switch self {
        case .traditionalStrengthTraining: return "Strength Training"
        case .running: return "Running"
        case .walking: return "Walking"
        case .cycling: return "Cycling"
        case .yoga: return "Yoga"
        case .functionalStrengthTraining: return "Functional Strength"
        case .highIntensityIntervalTraining: return "HIIT"
        case .mindAndBody: return "Mind & Body"
        default:
            // Reasonable fallback that doesn't leak raw enum names in the UI.
            return "Workout"
        }
    }
}
