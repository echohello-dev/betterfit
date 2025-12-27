import SwiftUI

struct ThemePickerView: View {
    @Binding var selectedTheme: AppTheme

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

                                Spacer()

                                if theme == selectedTheme {
                                    Image(systemName: "checkmark")
                                        .font(.body.weight(.bold))
                                        .foregroundStyle(theme.accent)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section("Tip") {
                    Text(
                        "Pick a theme that matches your training vibe. You can change this anytime."
                    )
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Appearance")
        }
    }
}

private struct ThemeSwatch: View {
    let theme: AppTheme

    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(theme.backgroundGradient)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(theme.cardStroke, lineWidth: 1)
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
    ThemePickerView(selectedTheme: $theme)
}
