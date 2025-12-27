import SwiftUI

struct TrendsView: View {
    let theme: AppTheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Trends")
                    .bfHeading(theme: theme, size: 36, relativeTo: .largeTitle)

                BFCard(theme: theme) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Coming soon")
                            .bfHeading(theme: theme, size: 18, relativeTo: .headline)
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
