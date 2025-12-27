import BetterFit
import SwiftUI

struct RootTabView: View {
    let betterFit: BetterFit
    let theme: AppTheme
    @State private var selectedTab = 0
    @State private var showingSearch = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case 0:
                    NavigationStack {
                        WorkoutHomeView(betterFit: betterFit, theme: theme)
                    }
                case 1:
                    NavigationStack {
                        TrendsView(theme: theme)
                    }
                case 2:
                    NavigationStack {
                        RecoveryView(betterFit: betterFit, theme: theme)
                    }
                case 3:
                    NavigationStack {
                        ProfileView(theme: theme)
                    }
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Floating nav bar
            FloatingNavBar(selectedTab: $selectedTab, theme: theme) {
                showingSearch = true
            }

        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $showingSearch) {
            AppSearchView(theme: theme, betterFit: betterFit)
                .presentationDetents([.large])
        }
    }
}

struct FloatingNavBar: View {
    @Binding var selectedTab: Int
    let theme: AppTheme
    let onSearch: () -> Void

    @Namespace private var glassNamespace

    var body: some View {
        HStack(spacing: 12) {
            if #available(iOS 26.0, *) {
                GlassEffectContainer(spacing: 12) {
                    HStack(spacing: 12) {
                        NavButton(
                            icon: "figure.run",
                            isSelected: selectedTab == 0,
                            theme: theme
                        ) {
                            selectedTab = 0
                        }
                        .glassEffectID("tab.workout", in: glassNamespace)

                        NavButton(
                            icon: "waveform",
                            label: "Plan",
                            isSelected: selectedTab == 1,
                            theme: theme
                        ) {
                            selectedTab = 1
                        }
                        .glassEffectID("tab.plan", in: glassNamespace)

                        NavButton(
                            icon: "clock",
                            isSelected: selectedTab == 2,
                            theme: theme
                        ) {
                            selectedTab = 2
                        }
                        .glassEffectID("tab.recovery", in: glassNamespace)
                    }
                }

                BFChromeIconButton(
                    systemImage: "magnifyingglass",
                    accessibilityLabel: "Search",
                    theme: theme
                ) {
                    onSearch()
                }
            } else {
                HStack(spacing: 20) {
                    NavButton(
                        icon: "figure.run",
                        isSelected: selectedTab == 0,
                        theme: theme
                    ) {
                        selectedTab = 0
                    }

                    NavButton(
                        icon: "waveform",
                        label: "Plan",
                        isSelected: selectedTab == 1,
                        theme: theme
                    ) {
                        selectedTab = 1
                    }

                    NavButton(
                        icon: "clock",
                        isSelected: selectedTab == 2,
                        theme: theme
                    ) {
                        selectedTab = 2
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            if #available(iOS 26.0, *) {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .glassEffect(.regular.interactive(), in: Capsule())
            } else {
                LiquidGlassBackground(theme: theme, cornerRadius: 40)
            }
        }
    }
}

struct NavButton: View {
    let icon: String
    var label: String?
    let isSelected: Bool
    let theme: AppTheme
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                    .symbolEffect(.bounce, value: isSelected)

                if let label = label {
                    Text(label)
                        .font(.body.weight(.semibold))
                }
            }
            .foregroundStyle(isSelected ? theme.accent : .primary)
            .frame(height: 44)
            .padding(.horizontal, label != nil ? 20 : 16)
            .background {
                if isSelected {
                    Capsule()
                        .fill(theme.accent.opacity(0.15))
                }
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .modifier(NavButtonGlassStyle(isSelected: isSelected, theme: theme))
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.snappy(duration: 0.15)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.snappy(duration: 0.15)) {
                        isPressed = false
                    }
                }
        )
    }
}

private struct NavButtonGlassStyle: ViewModifier {
    let isSelected: Bool
    let theme: AppTheme

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.interactive(), in: Capsule())
        } else {
            content
        }
    }
}

#Preview {
    let theme: AppTheme = .forest
    RootTabView(betterFit: BetterFit(), theme: theme)
        .tint(theme.accent)
        .preferredColorScheme(theme.preferredColorScheme)
}
