import SwiftUI

struct ExerciseDetailView: View {
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
        .background(theme.backgroundGradient.ignoresSafeArea())
        .toolbar(.visible, for: .navigationBar)
        .navigationTitle(exercise)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var heroSection: some View {
        Section {
            VStack(spacing: 16) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 56))
                    .foregroundStyle(theme.accent)
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
                            .background(theme.accent.opacity(0.15), in: Capsule())
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
            LabeledContent("Difficulty", value: exerciseInfo.difficulty)
            LabeledContent("Type", value: exerciseInfo.type)
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
