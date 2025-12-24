import SwiftUI

struct CalendarSheetView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedDate: Date
    let theme: AppTheme

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .tint(theme.accent)
                .padding(.horizontal, 8)

                Spacer(minLength: 0)
            }
            .padding(.top, 8)
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(theme.accent)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var date = Date.now
    CalendarSheetView(selectedDate: $date, theme: .midnight)
}
