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
                        .foregroundStyle(AppTheme.textSecondary)

                    TextField("Ex: Light", text: $question)
                        .darkFieldStyle()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Resposta (verso)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)

                    TextField("Ex: Luz", text: $answer)
                        .darkFieldStyle()
                }

                Spacer()
            }
            .padding(20)
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Novo Flashcard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(AppTheme.textSecondary)
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
            .toolbarBackground(AppTheme.cardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.medium])
    }
}
