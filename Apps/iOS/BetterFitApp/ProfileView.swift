import SwiftUI

struct ProfileView: View {
    let theme: AppTheme

    @AppStorage(AppTheme.storageKey) private var storedTheme: String = AppTheme.classic.rawValue

    @State private var showingThemePicker = false

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
            }

            Section("About") {
                LabeledContent("Version") {
                    Text("1.0")
                }
            }
        }
        .navigationTitle("You")
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
