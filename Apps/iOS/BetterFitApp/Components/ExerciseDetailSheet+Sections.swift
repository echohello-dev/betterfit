import BetterFit
import SwiftUI

// MARK: - Exercise Detail Sheet — header, quick actions & style

extension ExerciseDetailSheet {

    // MARK: - Header

    var exerciseHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise.displayName)
                .bfHeading(theme: theme, size: 28, relativeTo: .title)

            HStack(spacing: 12) {
                Label(exercise.displayCategory.rawValue, systemImage: categoryIcon)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(categoryColor)

                if !exercise.muscleGroups.isEmpty {
                    Text("•").foregroundStyle(BFColors.textSecondary(for: colorScheme))
                    Text(exercise.muscleGroups.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                }
            }
        }
    }

    // MARK: - Quick actions

    var quickActionButtons: some View {
        HStack(spacing: 12) {
            quickActionButton(icon: "arrow.triangle.2.circlepath", label: "Replace", color: .orange) {
                dismiss(); onReplace()
            }
            quickActionButton(icon: "link", label: "Superset", color: .purple) {
                dismiss(); onSuperset()
            }
            quickActionButton(icon: "trash", label: "Delete", color: .red) {
                dismiss(); onDelete()
            }
        }
    }

    func quickActionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(color)
                }
                Text(label)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(BFColors.textSecondary(for: colorScheme))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Style

    var gradientColors: [Color] {
        switch exercise.displayCategory {
        case .push: return [.blue, .cyan]
        case .pull: return [.purple, .pink]
        case .legs: return [.orange, .yellow]
        case .core: return [.yellow, .orange]
        case .cardio: return [.red, .orange]
        case .compound: return [.green, .teal]
        case .all: return [.gray, .secondary]
        }
    }

    var categoryIcon: String {
        switch exercise.displayCategory {
        case .push: return "arrow.up.circle"
        case .pull: return "arrow.down.circle"
        case .legs: return "figure.walk"
        case .core: return "circle.hexagongrid"
        case .cardio: return "heart"
        case .compound: return "dumbbell"
        case .all: return "figure.mixed.cardio"
        }
    }

    var categoryColor: Color {
        switch exercise.displayCategory {
        case .push: return .blue
        case .pull: return .purple
        case .legs: return .orange
        case .core: return .yellow
        case .cardio: return .red
        case .compound: return theme.accent
        case .all: return .gray
        }
    }
}
