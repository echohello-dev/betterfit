import SwiftUI

// MARK: - Summary data

struct WorkoutSummaryData {
    var name: String
    var duration: TimeInterval
    var volume: Double = 0
    var sets: Int = 0
    var note: String = "Good work. Consistency compounds."
    var exercises: [WorkoutSummaryExercise]
    /// Readiness change per trained muscle region, computed at finish from the
    /// session's logged sets and `BetterFit`'s recovery map. Empty when it
    /// cannot be derived — the summary hides the section rather than faking it.
    var recoveryEffects: [(muscle: String, from: Int, to: Int)] = []
}

struct WorkoutSummaryExercise: Identifiable {
    let id = UUID()
    let name: String
    let best: String
    let setsDone: Int
    let setsPlanned: Int
    let volume: Double
    let isPR: Bool
}

// MARK: - Workout summary — Ledger layout

struct WorkoutSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    let data: WorkoutSummaryData
    var onDone: () -> Void = {}

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    topBar
                    slab
                    content
                }
                .padding(.bottom, 120)
            }
            .background(BFColors.background(for: colorScheme).ignoresSafeArea())

            BFGlassDock {
                Button {
                    onDone()
                    dismiss()
                } label: {
                    Text("Done")
                        .font(BFTypography.headline)
                        .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                        .frame(maxWidth: .infinity)
                        .frame(height: BFControlSize.buttonLarge)
                        .background {
                            Capsule(style: .continuous)
                                .fill(BFColors.glassHighlight(for: colorScheme))
                                .overlay {
                                    Capsule(style: .continuous)
                                        .stroke(BFColors.glassBorder(for: colorScheme), lineWidth: 1)
                                }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .layoutPriority(1)
            }
            .padding(.bottom, 16)
        }
    }

    // MARK: - Top

    private var topBar: some View {
        HStack {
            Button {
                onDone()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Slab

    private var slab: some View {
        BFSlab {
            VStack(alignment: .leading, spacing: 0) {
                BFEyebrow(
                    text: "\(dateLabel) · Session complete",
                    color: BFColors.identityInk.opacity(0.6)
                )
                Text(data.name)
                    .font(BFTypography.display)
                    .tracking(BFTypography.displayTracking)
                    .foregroundStyle(BFColors.identityInk)
                    .padding(.top, 10)

                BFSpecStrip(
                    items: [
                        BFSpecItem(value: durationLabel, label: "Duration"),
                        BFSpecItem(value: volumeLabel, label: "Volume kg"),
                        BFSpecItem(value: "\(data.sets)", label: "Sets"),
                    ],
                    ink: BFColors.identityInk
                )
                .padding(.top, 4)

                Text(data.note)
                    .font(BFTypography.subheadlineEmphasis)
                    .foregroundStyle(BFColors.identityInk)
                    .padding(.top, 18)
                    .padding(.top, 16)
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(BFColors.identityInk.opacity(0.2))
                            .frame(height: 1.5)
                    }
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Content

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            let prs = data.exercises.filter(\.isPR)
            if !prs.isEmpty {
                BFSectionRule(label: "New records", trailing: "\(prs.count)")
                ForEach(prs) { ex in
                    BFLedgerRow(
                        gutterAccent: true,
                        systemImage: "medal.fill",
                        title: ex.name,
                        meta: "Personal best"
                    ) {
                        BFLedgerTrailing(value: ex.best)
                    }
                }
            }

            BFSectionRule(label: "What you lifted", trailing: "\(data.exercises.count) exercises")
            ForEach(Array(data.exercises.enumerated()), id: \.element.id) { index, ex in
                BFLedgerRow(
                    gutter: String(format: "%02d", index + 1),
                    gutterAccent: ex.isPR,
                    title: ex.name,
                    meta: "Best \(ex.best) · \(ex.setsDone) of \(ex.setsPlanned) sets"
                ) {
                    BFLedgerTrailing(value: volumeShort(ex.volume), meta: "kg")
                }
            }

            if !data.recoveryEffects.isEmpty {
                BFSectionRule(label: "Effect on recovery")
                ForEach(Array(data.recoveryEffects.enumerated()), id: \.offset) { _, effect in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            Text(effect.muscle)
                                .font(BFTypography.bodyEmphasis)
                                .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                            Spacer()
                            Text("\(effect.from)%")
                                .font(BFTypography.footnote)
                                .monospacedDigit()
                                .foregroundStyle(BFColors.textTertiary(for: colorScheme))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(BFColors.textTertiary(for: colorScheme))
                            Text("\(effect.to)%")
                                .font(BFTypography.subheadlineEmphasis)
                                .monospacedDigit()
                                .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                        }
                        BFBar(progress: Double(effect.to) / 100.0, color: BFColors.yellowDeep)
                    }
                    .padding(.vertical, 13)
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(BFColors.separator(for: colorScheme))
                            .frame(height: 1)
                    }
                }
            }

            BFSectionRule(label: "Next")
            BFLedgerRow(
                systemImage: "calendar",
                title: "Keep the streak going",
                meta: "Your next session is ready on Plan"
            ) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(BFColors.textTertiary(for: colorScheme))
            }
        }
        .padding(.horizontal, BFSpacing.pageHorizontal)
    }

    // MARK: - Format

    private var dateLabel: String {
        Date.now.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
    }

    private var durationLabel: String {
        let mins = Int(data.duration / 60)
        return "\(mins)'"
    }

    private var volumeLabel: String {
        if data.volume >= 1000 {
            return String(format: "%.1fk", data.volume / 1000)
        }
        return data.volume > 0 ? String(format: "%.0f", data.volume) : "—"
    }

    private func volumeShort(_ value: Double) -> String {
        if value >= 1000 { return String(format: "%.1fk", value / 1000) }
        return value > 0 ? String(format: "%.0f", value) : "—"
    }
}

#Preview {
    WorkoutSummaryView(
        data: WorkoutSummaryData(
            name: "Pull Day",
            duration: 44 * 60,
            volume: 6700,
            sets: 22,
            note: "Strongest pull session this month. Cable row went up 4 kg.",
            exercises: [
                WorkoutSummaryExercise(name: "Lat pulldown", best: "50 kg × 8", setsDone: 3, setsPlanned: 3, volume: 1200, isPR: false),
                WorkoutSummaryExercise(name: "Cable row", best: "64 kg × 8", setsDone: 4, setsPlanned: 4, volume: 2000, isPR: true),
            ],
            recoveryEffects: [
                (muscle: "Back", from: 96, to: 48),
                (muscle: "Arms", from: 72, to: 48),
            ]
        )
    )
    .preferredColorScheme(.dark)
}
