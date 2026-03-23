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
        NavigationStack {
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
            .padding(20)
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Novo Baralho")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Criar") {
                        onCreate(name, resolvedAbbreviation)
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.accent)
                    .disabled(name.isEmpty)
                }
            }
            .toolbarBackground(AppTheme.cardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.medium])
    }
}
