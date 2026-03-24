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
                        .foregroundStyle(AppTheme.textDark)

                    TextField(
                        "",
                        text: $name,
                        prompt: Text("Ex: Inglês Básico").foregroundStyle(Color(.lightGray))
                    )
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.white)
                        .foregroundStyle(AppTheme.textDark)
                        .tint(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall))
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Abreviação")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.textDark)

                        Text("(opcional)")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(AppTheme.textDark.opacity(0.4))
                    }

                    TextField(
                        "",
                        text: $abbreviation,
                        prompt: Text("Ex: ABC").foregroundStyle(Color(.lightGray))
                    )
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.white)
                        .foregroundStyle(AppTheme.textDark)
                        .tint(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall))
                        .onChange(of: abbreviation) { _, newValue in
                            abbreviation = String(newValue.prefix(4)).uppercased()
                        }
                }

                Spacer()
            }
            .padding(20)
            .navigationTitle("Novo Baralho")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(.black)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Criar") {
                        onCreate(name, resolvedAbbreviation)
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .disabled(name.isEmpty)
                }
            }
            .toolbarBackground(Color.clear, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
        }
        .presentationDetents([.medium])
        .presentationBackground(AppTheme.sheetBackground)
        .presentationCornerRadius(24)
    }
}
