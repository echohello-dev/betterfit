import SwiftUI

struct SettingDetailView: View {
    @Environment(\.colorScheme) private var colorScheme
    let settingId: String
    let title: String
    let theme: AppTheme

    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: iconForSetting)
                        .font(.system(size: 44))
                        .foregroundStyle(colorForSetting)

                    Text(descriptionForSetting)
                        .font(.subheadline)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }

            Section {
                switch settingId {
                case "result.notifications", "notifications":
                    notificationsContent
                case "result.health", "health":
                    healthContent
                case "result.units", "units":
                    unitsContent
                case "result.editProfile", "editProfile":
                    profileContent
                case "result.privacy", "privacy":
                    privacyContent
                case "result.terms", "terms":
                    termsContent
                default:
                    Text("Setting not found")
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                        .listRowBackground(BFColors.surface(for: colorScheme))
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .bfPageBackground()
        .navigationTitle(title)
    }

    // MARK: - Setting Content

    @ViewBuilder
    private var notificationsContent: some View {
        Toggle("Workout Reminders", isOn: .constant(true))
            .tint(theme.accent)
            .listRowBackground(BFColors.surface(for: colorScheme))

        Toggle("Rest Day Suggestions", isOn: .constant(true))
            .tint(theme.accent)
            .listRowBackground(BFColors.surface(for: colorScheme))

        Toggle("Achievement Alerts", isOn: .constant(true))
            .tint(theme.accent)
            .listRowBackground(BFColors.surface(for: colorScheme))

        Toggle("Weekly Summary", isOn: .constant(false))
            .tint(theme.accent)
            .listRowBackground(BFColors.surface(for: colorScheme))
    }

    @ViewBuilder
    private var healthContent: some View {
        HStack {
            Text("Status")
            Spacer()
            Text("Connected")
                .foregroundStyle(BFColors.success)
        }
        .listRowBackground(BFColors.surface(for: colorScheme))

        Toggle("Sync Workouts", isOn: .constant(true))
            .tint(theme.accent)
            .listRowBackground(BFColors.surface(for: colorScheme))

        Toggle("Sync Heart Rate", isOn: .constant(true))
            .tint(theme.accent)
            .listRowBackground(BFColors.surface(for: colorScheme))

        Toggle("Sync Calories", isOn: .constant(true))
            .tint(theme.accent)
            .listRowBackground(BFColors.surface(for: colorScheme))
    }

    @ViewBuilder
    private var unitsContent: some View {
        HStack {
            Text("Weight")
            Spacer()
            Text("lbs")
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))
        }
        .listRowBackground(BFColors.surface(for: colorScheme))

        HStack {
            Text("Distance")
            Spacer()
            Text("miles")
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))
        }
        .listRowBackground(BFColors.surface(for: colorScheme))

        HStack {
            Text("Height")
            Spacer()
            Text("ft/in")
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))
        }
        .listRowBackground(BFColors.surface(for: colorScheme))
    }

    @ViewBuilder
    private var profileContent: some View {
        HStack {
            Text("Display Name")
            Spacer()
            Text("Johnny")
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))
        }
        .listRowBackground(BFColors.surface(for: colorScheme))

        HStack {
            Text("Email")
            Spacer()
            Text("johnny@example.com")
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))
        }
        .listRowBackground(BFColors.surface(for: colorScheme))

        Button("Change Password") {
            // Change password action
        }
        .foregroundStyle(theme.accent)
        .listRowBackground(BFColors.surface(for: colorScheme))
    }

    @ViewBuilder
    private var privacyContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your privacy is important to us.")
                .font(.subheadline)

            Text(
                "We collect only the data necessary to provide you with a personalized fitness experience. Your workout data is stored securely and never shared with third parties without your consent."
            )
            .font(.caption)
            .foregroundStyle(BFColors.textSecondary(for: colorScheme))

            Link(
                "Read Full Privacy Policy",
                destination: URL(string: "https://betterfit.app/privacy")!
            )
            .font(.subheadline)
            .foregroundStyle(theme.accent)
        }
        .padding(.vertical, 4)
        .listRowBackground(BFColors.surface(for: colorScheme))
    }

    @ViewBuilder
    private var termsContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By using BetterFit, you agree to our terms of service.")
                .font(.subheadline)

            Text(
                "These terms govern your use of the app and outline your rights and responsibilities as a user."
            )
            .font(.caption)
            .foregroundStyle(BFColors.textSecondary(for: colorScheme))

            Link(
                "Read Full Terms of Service",
                destination: URL(string: "https://betterfit.app/terms")!
            )
            .font(.subheadline)
            .foregroundStyle(theme.accent)
        }
        .padding(.vertical, 4)
        .listRowBackground(BFColors.surface(for: colorScheme))
    }

    // MARK: - Helpers

    private var iconForSetting: String {
        switch settingId {
        case "result.notifications", "notifications": return "bell.fill"
        case "result.health", "health": return "heart.fill"
        case "result.units", "units": return "ruler.fill"
        case "result.editProfile", "editProfile": return "person.fill"
        case "result.privacy", "privacy": return "hand.raised.fill"
        case "result.terms", "terms": return "doc.text.fill"
        default: return "gearshape.fill"
        }
    }

    private var colorForSetting: Color {
        switch settingId {
        case "result.notifications", "notifications": return theme.accent
        case "result.health", "health": return .red
        case "result.units", "units": return theme.accent
        case "result.editProfile", "editProfile": return theme.accent
        case "result.privacy", "privacy": return .blue
        case "result.terms", "terms": return .gray
        default: return .gray
        }
    }

    private var descriptionForSetting: String {
        switch settingId {
        case "result.notifications", "notifications":
            return "Control when and how BetterFit notifies you"
        case "result.health", "health":
            return "Sync your workouts with Apple Health"
        case "result.units", "units":
            return "Choose your preferred measurement units"
        case "result.editProfile", "editProfile":
            return "Update your profile information"
        case "result.privacy", "privacy":
            return "Learn how we protect your data"
        case "result.terms", "terms":
            return "Review our terms of service"
        default:
            return "Configure this setting"
        }
    }
}

#Preview {
    NavigationStack {
        SettingDetailView(
            settingId: "notifications",
            title: "Notifications",
            theme: .midnight
        )
    }
}
