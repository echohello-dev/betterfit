import SwiftUI

struct TrendsView: View {
    let theme: AppTheme

    @State private var showingSearch = false

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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSearch = true
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.body.weight(.semibold))
                        .frame(width: 34, height: 34)
                        .background { LiquidGlassCircleBackground(theme: theme) }
                }
                .accessibilityLabel("Search")
            }
        }
        .sheet(isPresented: $showingSearch) {
            AppSearchView(theme: theme, betterFit: nil)
                .presentationDetents([.large])
        }
    }
}

#Preview {
    TrendsView(theme: .midnight)
}
