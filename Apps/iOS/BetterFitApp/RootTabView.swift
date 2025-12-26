import BetterFit
import SwiftUI

struct RootTabView: View {
    let betterFit: BetterFit
    let theme: AppTheme
    @State private var selectedTab = 0

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
            FloatingNavBar(selectedTab: $selectedTab, theme: theme)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct FloatingNavBar: View {
    @Binding var selectedTab: Int
    let theme: AppTheme

    var body: some View {
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
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
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

#Preview {
    RootTabView(betterFit: BetterFit(), theme: .forest)
}
