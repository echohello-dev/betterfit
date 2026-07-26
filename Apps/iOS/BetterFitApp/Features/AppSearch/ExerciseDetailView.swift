import SwiftUI

struct ExerciseDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    let exercise: String
    let subtitle: String
    let theme: AppTheme

    private var muscleGroups: [String] {
        subtitle.components(separatedBy: " • ")
    }

    private var exerciseInfo: ExerciseInfo {
        ExerciseInfo.data[exercise] ?? ExerciseInfo.placeholder
    }

    var body: some View {
        List {
            heroSection
            overviewSection
            instructionsSection
            tipsSection
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .bfPageBackground()
        .toolbar(.visible, for: .navigationBar)
        .navigationTitle(exercise)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var heroSection: some View {
        Section {
            VStack(spacing: 16) {
                FitnessIcon(systemImage: "figure.strengthtraining.traditional", size: 56, color: theme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)

                Text(exercise)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                HStack(spacing: 8) {
                    ForEach(muscleGroups, id: \.self) { muscle in
                        Text(muscle)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(theme.accentSurface(0.15, for: colorScheme), in: Capsule())
                            .foregroundStyle(theme.accent)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
        }
    }

    private var overviewSection: some View {
        Section {
            LabeledContent("Equipment", value: exerciseInfo.equipment)
                .listRowBackground(BFColors.surface(for: colorScheme))
            LabeledContent("Difficulty", value: exerciseInfo.difficulty)
                .listRowBackground(BFColors.surface(for: colorScheme))
            LabeledContent("Type", value: exerciseInfo.type)
                .listRowBackground(BFColors.surface(for: colorScheme))
        } header: {
            Text("Overview")
        }
    }

    private var instructionsSection: some View {
        Section {
            ForEach(Array(exerciseInfo.instructions.enumerated()), id: \.offset) {
                index, instruction in
                Label {
                    Text(instruction)
                } icon: {
                    Text("\(index + 1)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(theme.accent, in: Circle())
                }
                .listRowBackground(BFColors.surface(for: colorScheme))
            }
        } header: {
            Text("How to Perform")
        }
    }

    private var tipsSection: some View {
        Section {
            ForEach(exerciseInfo.tips, id: \.self) { tip in
                Label {
                    Text(tip)
                } icon: {
                    Image(systemName: "lightbulb")
                        .foregroundStyle(.yellow)
                }
                .listRowBackground(BFColors.surface(for: colorScheme))
            }
        } header: {
            Text("Tips")
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseDetailView(
            exercise: "Bench Press",
            subtitle: "Chest • Triceps",
            theme: .bold
        )
    }
}
