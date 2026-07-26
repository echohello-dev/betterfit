import BetterFit
import SwiftUI

// MARK: - Settings Sheet
//
// Lightweight settings panel. Lives in the Profile view as a single
// `Settings` row, opens as a sheet. Sections:
//   - Units (lb / kg) — persisted via WeightUnitSetting
//   - Notifications (workout reminders)
//   - Account (sign out, delete) — only when handlers are provided
//   - About (version, build, feedback)

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage(WeightUnitSetting.storageKey) private var weightUnitRaw: String = WeightUnitSetting.lbs.rawValue
    @AppStorage("betterfit.settings.notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("betterfit.settings.workoutReminders") private var workoutReminders: Bool = true

    /// Display label for the currently selected unit (shown in the
    /// settings section subtitle if needed).
    private var currentUnit: WeightUnitSetting {
        WeightUnitSetting(rawValue: weightUnitRaw) ?? .lbs
    }

    private func displayName(for unit: WeightUnitSetting) -> String {
        switch unit {
        case .lbs: return "Pounds (lb)"
        case .kg: return "Kilograms (kg)"
        }
    }

    let onSignOut: (() -> Void)?
    let onDeleteAccount: (() -> Void)?

    init(
        onSignOut: (() -> Void)? = nil,
        onDeleteAccount: (() -> Void)? = nil
    ) {
        self.onSignOut = onSignOut
        self.onDeleteAccount = onDeleteAccount
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BFSpacing.lg) {
                    unitsSection
                    notificationsSection
                    accountSection
                    aboutSection
                }
                .padding(.horizontal, BFSpacing.lg)
                .padding(.vertical, BFSpacing.md)
            }
            .background(BFColors.background(for: colorScheme))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityIdentifier("settings-sheet")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("settings-done")
                }
            }
        }
    }

    // MARK: - Sections

    private var unitsSection: some View {
        SettingsSection(
            title: "Units",
            systemImage: "scalemass",
            tint: BFColors.brandAccent
        ) {
            VStack(spacing: 0) {
                let units: [WeightUnitSetting] = [.lbs, .kg]
                ForEach(units, id: \.self) { unit in
                    SettingsRadioRow(
                        title: displayName(for: unit),
                        isSelected: weightUnitRaw == unit.rawValue
                    ) {
                        weightUnitRaw = unit.rawValue
                    }
                    if unit != .kg {
                        SettingsDivider()
                    }
                }
            }
        }
    }

    private var notificationsSection: some View {
        SettingsSection(
            title: "Notifications",
            systemImage: "bell.badge",
            tint: .blue
        ) {
            VStack(spacing: 0) {
                SettingsToggleRow(
                    title: "Workout reminders",
                    subtitle: "Daily nudge when it’s time to lift",
                    isOn: $workoutReminders
                )
                SettingsDivider()
                SettingsToggleRow(
                    title: "All notifications",
                    subtitle: "Pause everything when off",
                    isOn: $notificationsEnabled
                )
            }
        }
    }

    @ViewBuilder
    private var accountSection: some View {
        if onSignOut != nil || onDeleteAccount != nil {
            SettingsSection(
                title: "Account",
                systemImage: "person.crop.circle",
                tint: .green
            ) {
                VStack(spacing: 0) {
                    if let onSignOut {
                        Button(role: .destructive) {
                            onSignOut()
                            dismiss()
                        } label: {
                            SettingsRowContent(
                                title: "Sign Out",
                                subtitle: "Sign out of this account on this device",
                                trailing: AnyView(
                                    Image(systemName: "arrow.right.square")
                                        .font(.body)
                                        .foregroundStyle(BFColors.textTertiary(for: colorScheme))
                                )
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("settings-sign-out")
                    }
                    if let onDeleteAccount {
                        if onSignOut != nil { SettingsDivider() }
                        Button(role: .destructive) {
                            onDeleteAccount()
                        } label: {
                            SettingsRowContent(
                                title: "Delete Account",
                                subtitle: "Permanently remove your account and data",
                                trailing: AnyView(
                                    Image(systemName: "trash")
                                        .font(.body)
                                        .foregroundStyle(BFColors.danger)
                                )
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("settings-delete-account")
                    }
                }
            }
        }
    }

    private var aboutSection: some View {
        SettingsSection(
            title: "About",
            systemImage: "info.circle",
            tint: BFColors.textSecondary(for: colorScheme)
        ) {
            VStack(spacing: 0) {
                SettingsStaticRow(
                    title: "Version",
                    value: appVersion
                )
                SettingsDivider()
                SettingsStaticRow(
                    title: "Build",
                    value: appBuild
                )
                SettingsDivider()
                SettingsLinkRow(
                    title: "Send feedback",
                    systemImage: "envelope"
                ) {
                    // TODO: open mailto: or feedback sheet
                }
            }
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

// MARK: - Layout primitives

/// One settings card: tinted icon header + body content.
struct SettingsSection<Content: View>: View {
    let title: String
    let systemImage: String
    let tint: Color
    @ViewBuilder var content: Content

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: BFSpacing.sm) {
            HStack(spacing: BFSpacing.xs) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(tint)
                Text(title.uppercased())
                    .font(BFTypography.captionEmphasis)
                    .tracking(1.0)
                    .foregroundStyle(tint)
            }
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: BFRadius.card, style: .continuous)
                    .fill(BFColors.surface(for: colorScheme))
            )
            .overlay {
                RoundedRectangle(cornerRadius: BFRadius.card, style: .continuous)
                    .stroke(BFColors.border(for: colorScheme), lineWidth: 1)
            }
        }
    }
}

/// Thin hairline between rows inside a settings section.
struct SettingsDivider: View {
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        Rectangle()
            .fill(BFColors.separator(for: colorScheme))
            .frame(height: 1)
            .padding(.leading, 56)
    }
}

/// One row inside a section. Title on the left, trailing widget on
/// the right (icon, checkmark, value, etc).
struct SettingsRowContent: View {
    let title: String
    var subtitle: String? = nil
    let trailing: AnyView

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: BFSpacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(BFTypography.subheadline)
                    .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                if let subtitle {
                    Text(subtitle)
                        .font(BFTypography.caption)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                }
            }
            Spacer()
            trailing
        }
        .padding(.horizontal, BFSpacing.lg)
        .padding(.vertical, BFSpacing.md)
        .contentShape(Rectangle())
    }
}

/// Toggle row (native SwiftUI switch on the right).
struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        SettingsRowContent(
            title: title,
            subtitle: subtitle,
            trailing: AnyView(
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .tint(BFColors.brandAccent)
            )
        )
    }
}

/// Radio row (single selection inside a multi-row section).
struct SettingsRadioRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            SettingsRowContent(
                title: title,
                trailing: AnyView(
                    Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(isSelected ? BFColors.brandAccent : BFColors.textTertiary(for: colorScheme))
                        .font(.system(size: 22, weight: .semibold))
                )
            )
        }
        .buttonStyle(.plain)
    }
}

/// Static read-only row (e.g. Version: 1.0.0).
struct SettingsStaticRow: View {
    let title: String
    let value: String

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        SettingsRowContent(
            title: title,
            trailing: AnyView(
                Text(value)
                    .font(BFTypography.subheadline)
                    .foregroundStyle(BFColors.textSecondary(for: colorScheme))
            )
        )
    }
}

/// Tap-to-act row (chevron trailing).
struct SettingsLinkRow: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            SettingsRowContent(
                title: title,
                trailing: AnyView(
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BFColors.textTertiary(for: colorScheme))
                )
            )
        }
        .buttonStyle(.plain)
    }
}