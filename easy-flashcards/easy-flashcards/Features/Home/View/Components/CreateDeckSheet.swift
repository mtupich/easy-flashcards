import SwiftUI

struct CreateDeckSheet: View {

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var abbreviation = ""

    let onCreate: (String, String) -> Void

    private var resolvedAbbreviation: String {
        if abbreviation.isEmpty {
            return String(name.prefix(3)).uppercased()
        }
        return abbreviation
    }

    var body: some View {
        VStack(spacing: 0) {
            sheetIndicator
            sheetHeader
            sheetContent
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "252550"))
        )
        .padding(.horizontal, 8)
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
    }

    private var sheetIndicator: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(AppTheme.textSecondary.opacity(0.4))
            .frame(width: 36, height: 5)
            .padding(.top, 12)
            .padding(.bottom, 16)
    }

    private var sheetHeader: some View {
        HStack {
            Button("Cancelar") { dismiss() }
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.textSecondary)

            Spacer()

            Text("Novo Baralho")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)

            Spacer()

            Button("Criar") {
                onCreate(name, resolvedAbbreviation)
                dismiss()
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(name.isEmpty ? AppTheme.accent.opacity(0.3) : AppTheme.accent)
            .disabled(name.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }

    private var sheetContent: some View {
        VStack(spacing: AppTheme.spacingLarge) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Nome do Baralho")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)

                TextField("Ex: Inglês Básico", text: $name)
                    .darkFieldStyle()
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Abreviação")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)

                    Text("(opcional)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(AppTheme.textSecondary.opacity(0.6))
                }

                TextField("Ex: ABC", text: $abbreviation)
                    .darkFieldStyle()
                    .onChange(of: abbreviation) { _, newValue in
                        abbreviation = String(newValue.prefix(4)).uppercased()
                    }
            }

            Spacer()
        }
        .padding(.horizontal, 20)
    }
}
