import BetterFit
import SwiftUI

// MARK: - Equipment swap sheet

struct EquipmentSwapSheet: View {
    let theme: AppTheme
    @Binding var availableEquipment: Set<Equipment>
    let onApply: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            List {
                ForEach(Equipment.allCases, id: \.self) { eq in
                    Button {
                        if availableEquipment.contains(eq) {
                            availableEquipment.remove(eq)
                        } else {
                            availableEquipment.insert(eq)
                        }
                    } label: {
                        HStack {
                            Text(eq.rawValue.capitalized)
                                .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                            Spacer()
                            if availableEquipment.contains(eq) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(BFColors.accentText(for: colorScheme))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Equipment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        onApply()
                        dismiss()
                    }
                }
            }
        }
    }
}
