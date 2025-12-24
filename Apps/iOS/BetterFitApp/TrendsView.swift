import SwiftUI

struct TrendsView: View {
    let theme: AppTheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Trends")
                    .font(.largeTitle.weight(.bold))

                BFCard(theme: theme) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Coming soon")
                            .font(.headline)
                        Text("Weekly volume, recovery trendlines, and PR tracking will live here.")
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(16)
        }
        .background(theme.backgroundGradient.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    TrendsView(theme: .midnight)
}
