import BetterFit
import SwiftUI

extension WorkoutHomeView {
    // MARK: - Components

    struct SemiCircularGauge: View {
        let value: Double
        let theme: AppTheme

        var body: some View {
            let clamped = min(max(value, 0), 1)

            ZStack {
                Circle()
                    .trim(from: 0, to: 0.5)
                    .stroke(
                        theme.cardStroke.opacity(0.5),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )

                Circle()
                    .trim(from: 0, to: 0.5 * clamped)
                    .stroke(
                        theme.accent,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )

                Rectangle()
                    .fill(theme.accent.opacity(0.9))
                    .frame(width: 44, height: 2)
                    .offset(x: 22)
                    .rotationEffect(.degrees(180 * clamped))

                Circle()
                    .fill(theme.cardBackground)
                    .frame(width: 10, height: 10)
                    .overlay { Circle().stroke(theme.cardStroke, lineWidth: 1) }
            }
            .padding(.top, 2)
            .padding(.horizontal, 2)
        }
    }

    struct OverviewStat: View {
        let title: String
        let value: String
        let systemImage: String
        let theme: AppTheme

        var body: some View {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.accent)

                VStack(alignment: .leading, spacing: 0) {
                    Text(value)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                        .monospacedDigit()
                    Text(title)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    struct CategoryLegendDot: View {
        let label: String
        let percent: Int
        let color: Color
        let theme: AppTheme

        var body: some View {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 7, height: 7)
                Text("\(label) \(percent)%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }

    struct GoalStat: View {
        let icon: String
        let value: String
        let theme: AppTheme

        var body: some View {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(value)
                    .font(.body.weight(.semibold))
            }
            .foregroundStyle(.white)
        }
    }

    struct WorkoutSuggestionCard: View {
        let workout: Workout
        let theme: AppTheme
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                VStack(alignment: .leading, spacing: 12) {
                    // Preview image placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(theme.accent.opacity(0.3))
                            .frame(height: 140)

                        Image(systemName: iconForWorkout)
                            .font(.system(size: 48))
                            .foregroundStyle(theme.accent)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(workout.name)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .lineLimit(2)

                        HStack(spacing: 12) {
                            Label(
                                "\(workout.exercises.count) exercises", systemImage: "list.bullet")
                            Label("30min", systemImage: "clock")
                        }
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    }

                    Spacer()
                }
                .frame(width: 200)
                .padding(12)
                .background {
                    if #available(iOS 26.0, *) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
                    } else {
                        let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)
                        shape
                            .fill(.ultraThinMaterial)
                            .overlay { shape.stroke(theme.cardStroke, lineWidth: 1) }
                            .shadow(
                                color: Color.black.opacity(
                                    theme.preferredColorScheme == .dark ? 0.22 : 0.08),
                                radius: theme.preferredColorScheme == .dark ? 14 : 10,
                                x: 0,
                                y: 6
                            )
                    }
                }
            }
            .buttonStyle(.plain)
        }

        private var iconForWorkout: String {
            let name = workout.name.lowercased()
            if name.contains("run") { return "figure.run" }
            if name.contains("yoga") { return "figure.yoga" }
            if name.contains("strength") || name.contains("upper") { return "dumbbell.fill" }
            if name.contains("hiit") { return "flame.fill" }
            return "figure.mixed.cardio"
        }
    }

    struct FeatureRow: View {
        let icon: String
        let title: String
        let theme: AppTheme

        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(theme.accent)
                    .frame(width: 40)

                Text(title)
                    .font(.body.weight(.semibold))

                Spacer()
            }
            .padding(.horizontal)
        }
    }

    struct SubscriptionView: View {
        let theme: AppTheme
        @Environment(\.dismiss) private var dismiss

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // GO Club branding
                        ZStack {
                            Circle()
                                .fill(theme.accent)
                                .frame(width: 120, height: 120)

                            Text("GO")
                                .font(.system(size: 48, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .padding(.top, 40)

                        Text("Start your fitness journey")
                            .bfHeading(theme: theme, size: 32, relativeTo: .largeTitle)
                            .multilineTextAlignment(.center)

                        Text(
                            "First week free, then just $19.99/year\nLess than your monthly coffee habit!"
                        )
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)

                        VStack(spacing: 16) {
                            FeatureRow(icon: "sparkles", title: "AI-Powered Workouts", theme: theme)
                            FeatureRow(icon: "heart.fill", title: "Recovery Tracking", theme: theme)
                            FeatureRow(
                                icon: "chart.line.uptrend.xyaxis", title: "Progress Analytics",
                                theme: theme)
                            FeatureRow(
                                icon: "trophy.fill", title: "Achievements & Streaks", theme: theme)
                        }
                        .padding(.vertical)

                        Button {
                            // Start trial
                            dismiss()
                        } label: {
                            Text("Start Free Trial")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(theme.accent)
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal)

                        Button("Maybe Later") {
                            dismiss()
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .padding()
                }
                .background(theme.backgroundGradient.ignoresSafeArea())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    struct CustomHeatmapRangeSheet: View {
        let theme: AppTheme
        @Binding var start: Date
        @Binding var end: Date

        @Environment(\.dismiss) private var dismiss

        @State private var draftStart: Date = Date.now
        @State private var draftEnd: Date = Date.now

        var body: some View {
            NavigationStack {
                Form {
                    Section {
                        DatePicker("Start", selection: $draftStart, displayedComponents: [.date])
                        DatePicker("End", selection: $draftEnd, displayedComponents: [.date])
                    }

                    Section {
                        Button("Preset: Last 3 Years") {
                            let calendar = Calendar.current
                            let today = calendar.startOfDay(for: Date.now)
                            draftEnd = today
                            draftStart =
                                calendar.date(byAdding: .year, value: -3, to: today) ?? today
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(theme.backgroundGradient.ignoresSafeArea())
                .navigationTitle("Custom Range")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            start = draftStart
                            end = draftEnd
                            dismiss()
                        }
                        .font(.headline)
                    }
                }
            }
            .onAppear {
                draftStart = start
                draftEnd = end

                // If the stored custom range is effectively unset, default to last 3 years.
                if abs(draftStart.timeIntervalSince(draftEnd)) < 1 {
                    let calendar = Calendar.current
                    let today = calendar.startOfDay(for: Date.now)
                    draftEnd = today
                    draftStart = calendar.date(byAdding: .year, value: -3, to: today) ?? today
                }
            }
        }
    }

    struct ContributionHeatmap: View {
        let startDate: Date
        let endDate: Date
        let valuesByDay: [Date: Int]
        let theme: AppTheme

        @State private var didAutoScrollToEnd = false

        private let cell: CGFloat = 11
        private let gap: CGFloat = 4

        var body: some View {
            let calendar = Calendar.current
            let rangeStart = calendar.startOfDay(for: startDate)
            let rangeEnd = calendar.startOfDay(for: endDate)

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 14) {
                        ForEach(
                            monthStarts(
                                rangeStart: rangeStart, rangeEnd: rangeEnd, calendar: calendar),
                            id: \.self
                        ) { monthStart in
                            MonthBlock(
                                monthStart: monthStart,
                                rangeStart: rangeStart,
                                rangeEnd: rangeEnd,
                                valuesByDay: valuesByDay,
                                cell: cell,
                                gap: gap,
                                theme: theme
                            )
                            .id(monthStart)
                        }

                        Color.clear
                            .frame(width: 1, height: 1)
                            .id("heatmap-end")
                    }
                    .padding(.vertical, 2)
                }
                .onAppear {
                    guard !didAutoScrollToEnd else { return }
                    didAutoScrollToEnd = true
                    DispatchQueue.main.async {
                        proxy.scrollTo("heatmap-end", anchor: .trailing)
                    }
                }
                .onChange(of: endDate) {
                    DispatchQueue.main.async {
                        proxy.scrollTo("heatmap-end", anchor: .trailing)
                    }
                }
                .onChange(of: startDate) {
                    DispatchQueue.main.async {
                        proxy.scrollTo("heatmap-end", anchor: .trailing)
                    }
                }
            }
            .mask { RoundedRectangle(cornerRadius: 16, style: .continuous) }
        }

        private func monthStarts(rangeStart: Date, rangeEnd: Date, calendar: Calendar) -> [Date] {
            guard rangeStart <= rangeEnd else { return [] }
            guard
                let startOfStartMonth = calendar.date(
                    from: calendar.dateComponents([.year, .month], from: rangeStart)),
                let startOfEndMonth = calendar.date(
                    from: calendar.dateComponents([.year, .month], from: rangeEnd))
            else {
                return []
            }

            var months: [Date] = []
            var cursor = startOfStartMonth
            while cursor <= startOfEndMonth {
                months.append(cursor)
                guard let next = calendar.date(byAdding: .month, value: 1, to: cursor) else {
                    break
                }
                cursor = next
            }
            return months
        }

        private struct MonthBlock: View {
            let monthStart: Date
            let rangeStart: Date
            let rangeEnd: Date
            let valuesByDay: [Date: Int]
            let cell: CGFloat
            let gap: CGFloat
            let theme: AppTheme

            var body: some View {
                let calendar = Calendar.current
                let monthEnd = endOfMonth(for: monthStart, calendar: calendar)
                let clampedEnd = min(monthEnd, rangeEnd)
                let clampedStart = max(monthStart, rangeStart)

                VStack(alignment: .leading, spacing: 8) {
                    Text(monthStart.formatted(.dateTime.month(.abbreviated)))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    HStack(alignment: .top, spacing: gap) {
                        ForEach(
                            weekStarts(
                                forMonthStart: monthStart, monthEnd: clampedEnd, calendar: calendar),
                            id: \.self
                        ) { weekStart in
                            VStack(spacing: gap) {
                                ForEach(0..<7, id: \.self) { dayOffset in
                                    let date =
                                        calendar.date(
                                            byAdding: .day, value: dayOffset, to: weekStart)
                                        ?? weekStart
                                    DayCell(
                                        date: date,
                                        rangeStart: clampedStart,
                                        rangeEnd: clampedEnd,
                                        valuesByDay: valuesByDay,
                                        cell: cell,
                                        theme: theme
                                    )
                                }
                            }
                        }
                    }
                }
            }

            private func endOfMonth(for date: Date, calendar: Calendar) -> Date {
                guard
                    let start = calendar.date(
                        from: calendar.dateComponents([.year, .month], from: date)),
                    let next = calendar.date(byAdding: .month, value: 1, to: start),
                    let end = calendar.date(byAdding: .day, value: -1, to: next)
                else {
                    return date
                }
                return end
            }

            private func weekStarts(
                forMonthStart monthStart: Date, monthEnd: Date, calendar: Calendar
            ) -> [Date] {
                guard
                    let firstWeekStart = calendar.dateInterval(of: .weekOfYear, for: monthStart)?
                        .start,
                    let lastWeekStart = calendar.dateInterval(of: .weekOfYear, for: monthEnd)?.start
                else {
                    return []
                }

                var weeks: [Date] = []
                var cursor = firstWeekStart
                while cursor <= lastWeekStart {
                    weeks.append(cursor)
                    guard let next = calendar.date(byAdding: .day, value: 7, to: cursor) else {
                        break
                    }
                    cursor = next
                }
                return weeks
            }
        }

        private struct DayCell: View {
            let date: Date
            let rangeStart: Date
            let rangeEnd: Date
            let valuesByDay: [Date: Int]
            let cell: CGFloat
            let theme: AppTheme

            var body: some View {
                let calendar = Calendar.current
                let day = calendar.startOfDay(for: date)
                let isInRange =
                    day >= calendar.startOfDay(for: rangeStart)
                    && day <= calendar.startOfDay(for: rangeEnd)

                Group {
                    if isInRange {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(color(for: valuesByDay[day, default: 0]))
                            .overlay {
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .stroke(theme.cardStroke.opacity(0.7), lineWidth: 0.5)
                            }
                            .accessibilityLabel(
                                accessibilityText(day: day, count: valuesByDay[day, default: 0]))
                    } else {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(Color.clear)
                    }
                }
                .frame(width: cell, height: cell)
            }

            private func color(for count: Int) -> Color {
                switch count {
                case 0:
                    return theme.accent.opacity(0)
                case 1:
                    return theme.accent.opacity(0.18)
                case 2:
                    return theme.accent.opacity(0.34)
                case 3:
                    return theme.accent.opacity(0.52)
                default:
                    return theme.accent.opacity(0.75)
                }
            }

            private func accessibilityText(day: Date, count: Int) -> String {
                if count == 0 {
                    return "\(day.formatted(date: .abbreviated, time: .omitted)): no workouts"
                }
                if count == 1 {
                    return "\(day.formatted(date: .abbreviated, time: .omitted)): 1 workout"
                }
                return "\(day.formatted(date: .abbreviated, time: .omitted)): \(count) workouts"
            }
        }
    }
}
