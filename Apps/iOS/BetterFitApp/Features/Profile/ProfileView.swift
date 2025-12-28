import SwiftUI

struct ProfileView: View {
    let theme: AppTheme

    @AppStorage(AppTheme.storageKey) private var storedTheme: String = AppTheme.defaultTheme
        .rawValue

    @State private var showingThemePicker = false

    #if DEBUG
        @AppStorage("betterfit.workoutHome.demoMode") private var workoutHomeDemoModeEnabled = false
    #endif

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
                .listRowBackground(nativeRowBackground(cornerRadius: 14))
            }
            .listSectionSeparator(.hidden)

            #if DEBUG
                Section("Developer") {
                    Toggle(isOn: $workoutHomeDemoModeEnabled) {
                        Label("Demo Mode", systemImage: "testtube.2")
                    }
                    .listRowBackground(nativeRowBackground(cornerRadius: 14))

                    Text("Enables seeded demo data and demo-only UI behavior in Workout.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                }
                .listSectionSeparator(.hidden)
            #endif

            Section("About") {
                LabeledContent("Version") {
                    Text("1.0")
                }
                .listRowBackground(nativeRowBackground(cornerRadius: 14))
            }
            .listSectionSeparator(.hidden)
        }
        .navigationTitle("You")
        .scrollContentBackground(.hidden)
        .background(theme.backgroundGradient.ignoresSafeArea())
        .listStyle(.insetGrouped)
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

    private func nativeRowBackground(cornerRadius: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        return
            shape
            .fill(.regularMaterial)
            .overlay { shape.stroke(theme.cardStroke, lineWidth: 1) }
    }
}

#Preview {
    UserDefaults.standard.set(true, forKey: "betterfit.workoutHome.demoMode")
    return ProfileView(theme: .sunset)
}
