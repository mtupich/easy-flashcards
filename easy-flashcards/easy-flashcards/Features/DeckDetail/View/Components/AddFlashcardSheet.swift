import SwiftUI

struct AddFlashcardSheet: View {

    @Environment(\.dismiss) private var dismiss
    @State private var question = ""
    @State private var answer = ""

    let onAdd: (String, String) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.spacingLarge) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pergunta (frente)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.textDark)

                    TextField(
                        "",
                        text: $question,
                        prompt: Text("Ex: Light").foregroundStyle(Color(.lightGray))
                    )
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.white)
                        .foregroundStyle(AppTheme.textDark)
                        .tint(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Resposta (verso)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.textDark)

                    TextField(
                        "",
                        text: $answer,
                        prompt: Text("Ex: Luz").foregroundStyle(Color(.lightGray))
                    )
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.white)
                        .foregroundStyle(AppTheme.textDark)
                        .tint(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall))
                }

                Spacer()
            }
            .padding(20)
            .navigationTitle("Novo Flashcard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(.gray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Adicionar") {
                        onAdd(question, answer)
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.accent)
                    .disabled(question.isEmpty || answer.isEmpty)
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
