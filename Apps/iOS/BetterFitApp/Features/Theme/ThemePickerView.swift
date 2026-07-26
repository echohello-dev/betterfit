import BetterFit
import SwiftUI

struct ThemePickerView: View {
    @Binding var selectedTheme: AppTheme
    @Binding var appearance: AppearancePreference
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            List {
                Section("Themes") {
                    ForEach(AppTheme.allCases) { theme in
                        Button {
                            withAnimation(.snappy) {
                                selectedTheme = theme
                            }
                        } label: {
                            HStack(spacing: 12) {
                                ThemeSwatch(theme: theme)
                                    .frame(width: 44, height: 28)

                                Text(theme.displayName)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(BFColors.textPrimary(for: colorScheme))

                                Spacer()

                                if theme == selectedTheme {
                                    Image(systemName: "checkmark")
                                        .font(.body.weight(.bold))
                                        .foregroundStyle(theme.accent)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background {
                                let shape = RoundedRectangle(
                                    cornerRadius: BFRadius.medium, style: .continuous)
                                shape
                                    .fill(BFColors.surface(for: colorScheme))
                                    .overlay {
                                        shape.stroke(
                                            theme == selectedTheme
                                                ? theme.accent : BFColors.border(for: colorScheme),
                                            lineWidth: theme == selectedTheme ? 1.5 : 1
                                        )
                                    }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }

                Section("Appearance") {
                    ForEach(AppearancePreference.allCases) { mode in
                        Button {
                            withAnimation(.snappy) {
                                appearance = mode
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: mode.systemImage)
                                    .font(.body)
                                    .frame(width: 28)
                                    .foregroundStyle(selectedTheme.accent)

                                Text(mode.displayName)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(BFColors.textPrimary(for: colorScheme))

                                Spacer()

                                if mode == appearance {
                                    Image(systemName: "checkmark")
                                        .font(.body.weight(.bold))
                                        .foregroundStyle(selectedTheme.accent)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background {
                                let shape = RoundedRectangle(
                                    cornerRadius: BFRadius.medium, style: .continuous)
                                shape
                                    .fill(BFColors.surface(for: colorScheme))
                                    .overlay {
                                        shape.stroke(
                                            mode == appearance
                                                ? selectedTheme.accent
                                                : BFColors.border(for: colorScheme),
                                            lineWidth: mode == appearance ? 1.5 : 1
                                        )
                                    }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }

                Section("Tip") {
                    Text(
                        "Pick a theme that matches your training vibe. You can change this anytime."
                    )
                    .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                    .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .bfPageBackground()
            .navigationTitle("Appearance")
        }
    }
}

private struct ThemeSwatch: View {
    let theme: AppTheme
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(theme.backgroundGradient(for: colorScheme))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(BFColors.border(for: colorScheme), lineWidth: 1)
            }
            .overlay(alignment: .bottomTrailing) {
                Circle()
                    .fill(theme.accent)
                    .frame(width: 10, height: 10)
                    .padding(6)
            }
    }
}

#Preview {
    @Previewable @State var theme: AppTheme = .midnight
    @Previewable @State var appearance: AppearancePreference = .system
    ThemePickerView(selectedTheme: $theme, appearance: $appearance)
}
