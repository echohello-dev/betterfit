import Charts
import SwiftUI

struct TrendsView: View {
    let theme: AppTheme

    // MARK: - Mock Data

    struct VolumeData: Identifiable {
        let id = UUID()
        let day: String
        let volume: Double
    }

    struct RecoveryData: Identifiable {
        let id = UUID()
        let date: Date
        let percentage: Double
    }

    private var weeklyVolume: [VolumeData] {
        [
            VolumeData(day: "Mon", volume: 4200),
            VolumeData(day: "Tue", volume: 3800),
            VolumeData(day: "Wed", volume: 0),
            VolumeData(day: "Thu", volume: 5100),
            VolumeData(day: "Fri", volume: 4500),
            VolumeData(day: "Sat", volume: 2200),
            VolumeData(day: "Sun", volume: 0),
        ]
    }

    private var recoveryTrend: [RecoveryData] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).map { i in
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            // Mock a recovery trend that fluctuates
            let percentage = 60.0 + sin(Double(i)) * 20.0 + Double.random(in: -5...5)
            return RecoveryData(date: date, percentage: max(0, min(100, percentage)))
        }.reversed()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Trends")
                    .bfHeading(theme: theme, size: 36, relativeTo: .largeTitle)

                volumeSection
                recoverySection

                BFCard(theme: theme) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PR Tracking")
                            .bfHeading(theme: theme, size: 18, relativeTo: .headline)
                        Text("Personal records for your main lifts will appear here soon.")
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(16)
        }
        .background(theme.backgroundGradient.ignoresSafeArea())
    }

    private var volumeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Volume")
                .bfHeading(theme: theme, size: 20, relativeTo: .headline)

            BFCard(theme: theme) {
                Chart {
                    ForEach(weeklyVolume) { data in
                        BarMark(
                            x: .value("Day", data.day),
                            y: .value("Volume", data.volume)
                        )
                        .foregroundStyle(theme.accent.gradient)
                        .cornerRadius(4)
                    }
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
    }

    private var recoverySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recovery Trend")
                .bfHeading(theme: theme, size: 20, relativeTo: .headline)

            BFCard(theme: theme) {
                Chart {
                    ForEach(recoveryTrend) { data in
                        LineMark(
                            x: .value("Date", data.date),
                            y: .value("Recovery", data.percentage)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(theme.accent)
                        .symbol(Circle().strokeBorder(lineWidth: 2))

                        AreaMark(
                            x: .value("Date", data.date),
                            y: .value("Recovery", data.percentage)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(theme.accent.opacity(0.1).gradient)
                    }
                }
                .frame(height: 200)
                .chartYScale(domain: 0...100)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
            }
        }
    }
}

#Preview {
    TrendsView(theme: .midnight)
}
