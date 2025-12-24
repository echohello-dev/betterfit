import SwiftUI

struct ProfileView: View {
    let theme: AppTheme

    @AppStorage(AppTheme.storageKey) private var storedTheme: String = AppTheme.defaultTheme
        .rawValue

    @State private var showingThemePicker = false

    @State private var showingSearch = false

    var body: some View {
        List {
            Section("Appearance") {
                Button {
                    showingThemePicker = true
                } label: {
                    HStack {
                        Label("Theme", systemImage: "paintpalette")
                        Spacer(minLength: 0)
                        Text(AppTheme.fromStorage(storedTheme).displayName)
                            .foregroundStyle(.secondary)
                    }
                }
                .listRowBackground(LiquidGlassBackground(theme: theme, cornerRadius: 14))
            }
            .listSectionSeparator(.hidden)

            Section("About") {
                LabeledContent("Version") {
                    Text("1.0")
                }
                .listRowBackground(LiquidGlassBackground(theme: theme, cornerRadius: 14))
            }
            .listSectionSeparator(.hidden)
        }
        .navigationTitle("You")
        .scrollContentBackground(.hidden)
        .background(theme.backgroundGradient.ignoresSafeArea())
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                BFChromeIconButton(
                    systemImage: "magnifyingglass",
                    accessibilityLabel: "Search",
                    theme: theme
                ) {
                    showingSearch = true
                }
            }
        }
        .sheet(isPresented: $showingSearch) {
            AppSearchView(theme: theme, betterFit: nil)
                .presentationDetents([.large])
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
}

#Preview {
    ProfileView(theme: .sunset)
}
